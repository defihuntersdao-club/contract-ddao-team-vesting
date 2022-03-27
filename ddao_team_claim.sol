// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IToken
{
    function approve(address spender,uint256 amount)external;
    function allowance(address owner,address spender)external view returns(uint256);
    function balanceOf(address addr)external view returns(uint256);
    function decimals() external view  returns (uint8);
    function name() external view  returns (string memory);
    function symbol() external view  returns (string memory);
    function totalSupply() external view  returns (uint256);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transfer(address recipient, uint256 amount) external;
    function AdminGetToken(address tokenAddress, uint256 amount) external; 
}

contract DDAOTeamClaim is AccessControl
{
    using SafeMath  for uint256;
    using SafeERC20 for IERC20;

    uint48  constant public TimeStart 	= 1646092800; // 1 MAR 2022
    uint256 constant public AmountMax 	= 1680000;
    uint48  constant public TimeEnd 	= TimeStart + 24 * 86400*30;
    uint48  immutable public TimeDeploy;
    uint256 immutable public BlockDeploy;

    address public AddrDDAO = 0x90F3edc7D5298918F7BB51694134b07356F7d0C7;
    address public AddrProxy = 0x2E7bEC36f8642Cc3df83C19470bE089A5FAF98Fa;
    uint48  public TimeUpdate;
    uint48  public TimeStakeRecalc;

    mapping(uint8 => uint8)public Group;
    bool public Enable = true;

    mapping(uint8 => mapping(address => uint8))public Member;

    uint256 public HistoryNum;
    mapping (uint256 => history)public History;

    struct history
    {
	uint256 num;
	address addr;
	uint256 amount;
	uint256 payed;
	uint48 time;
	uint256 blk;
    }

    struct personal
    {
	uint8 id;
	uint256 staked;
	uint256 payed;
	uint48  added;
	uint48  updated;
    }
    mapping(uint8 => mapping(address => personal))public Personal;

    event eStakeRecalc(uint8 id,uint8 nn,address addr,uint256 amount,uint256 staked,uint256 payed,uint48 time);
    event eClaim(uint8 id,address addr,uint256 amount,uint256 payed,uint256 prev_staked);

	mapping(uint8 => mapping(uint8 => address))public GroupMember;
	mapping(uint8 => address[]) GroupMemberAddr;
	mapping(uint8 => uint8)public GroupLen;
	function GroupMemberAdd(uint8 id,address addr,uint8 val,uint48 time)public onlyAdmin
	{
	    require(GroupLen[id]<256,"The group is full");
	    if(TimeDeploy != block.timestamp)StakeRecalc();
	    GroupLen[id]++;
	    Member[id][addr] = val;
	    GroupMember[id][GroupLen[id]] = addr;
	    GroupMemberAddr[id].push(addr);
	    Personal[id][addr].id = GroupLen[id];
	    Personal[id][addr].staked = 0;
	    Personal[id][addr].payed = 0;

	    if(time != 0)
	    {
	    Personal[id][addr].updated = time;
	    }
	    else
	    {
	    Personal[id][addr].updated = uint48(block.timestamp);
	    }

	    if(TimeDeploy == block.timestamp && time == TimeStart)
	    {
	    Personal[id][addr].added = TimeStart;
	    }
	    else
	    {
	        if(time != 0)
    		{
	        Personal[id][addr].added = time;
    		}
    		else
    		{
    	        Personal[id][addr].added = uint48(block.timestamp);
    		}
	    }

	}
	function GroupMemberChange(uint8 id,address addr,uint8 val)public onlyAdmin
	{
	    Member[id][addr] = val;
	}
	function GroupMemberShow(uint8 id)public view returns(address[] memory out)
	{
		out = GroupMemberAddr[id];
	}
	function GroupMaxVal(uint8 id)public view returns(uint8 val)
	{
	    address a;
	    for(uint8 i=1;i <= GroupLen[id];i++)
	    {
		a = GroupMember[id][i]; 
		val += Member[id][a];
	    }
	}
	function GroupMemberVal(uint8 id,address addr)public view returns(uint8)
	{
	    return Member[id][addr];
	}
	constructor() 
	{
	TimeDeploy 	= uint48(block.timestamp);
	BlockDeploy 	= block.number;
	TimeUpdate = TimeStart;
        // TECH TEAM 
	Group[1] = 10;
	// ADVISER
	Group[2] = 10;
	// FUND
	Group[3] = 30;
	// FOUNDERS
	Group[4] = 50;

	    GroupLen[1] = 0;
	    GroupLen[2] = 0;
	    GroupLen[3] = 0;
	    GroupLen[4] = 0;
	    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
	    Admins.push(_msgSender());
	    //_setupRole(DEFAULT_ADMIN_ROLE, 0x208b02f98d36983982eA9c0cdC6B3208e0f198A3);
	    //AdminAdd(_msgSender());
	    AdminAdd(0x208b02f98d36983982eA9c0cdC6B3208e0f198A3);

		GroupMemberAdd(1,0x330eC7c6AfC3cF19511Ad4041e598B235D44862f,90,TimeStart);
		GroupMemberAdd(1,0x57266f25439B60A94e4a47Cbc1bF1A2A6C119109, 5,TimeStart);
		GroupMemberAdd(1,0x5BB72943dFd6201897d163D06DaEC4c4557Ab25c, 5,TimeStart);

		GroupMemberAdd(2,0xB7E0cC3b51AFD812C1C4aeFd437D3c5daC0D4efF,45,TimeStart);

		GroupMemberAdd(3,0x0954409a3cfA81F05fE7421f3Aa162146a28b848,10,TimeStart);

		GroupMemberAdd(4,0xeA10DD05CF0A12AB1BDBd202FA8707D3BFd08737,45,TimeStart);
		GroupMemberAdd(4,0xD54201a17a0b00F5726a38EE6bcCae1371631Dd6,45,TimeStart);

	    if( block.chainid == 80001)
	    {
		AddrDDAO = 0xE1F0e40846218bF2CACfEd40c00bE218F54C49f7;
		AddrProxy = 0xc17b56bbD2430242A66725f31D7f28586BeF8227;
	    }

	    if( block.chainid == 3)
	    {
		AddrDDAO = 0x086F80a0ebC2a92bBb3e4476b30f67D058a4c26A;
		AddrProxy = 0x8356B4Dd5397Dd8519512562c92b8EC14Df73541;
	    }

	    StakeRecalc();
	    GroupMemberAdd(1,0x34B40BA116d5Dec75548a9e9A8f15411461E8c70, 90,0);
	}

	// Start: Admin functions
	event adminModify(string txt, address addr);
	address[] Admins;
	modifier onlyAdmin() 
	{
		require(IsAdmin(_msgSender()), "Access for Admin's only");
		_;
	}
	function IsAdmin(address account) public virtual view returns (bool)
	{
		return hasRole(DEFAULT_ADMIN_ROLE, account);
	}
	function AdminAdd(address account) public virtual onlyAdmin
	{
		require(!IsAdmin(account),'Account already ADMIN');
		grantRole(DEFAULT_ADMIN_ROLE, account);
		emit adminModify('Admin added',account);
		Admins.push(account);
	}
	function AdminDel(address account) public virtual onlyAdmin
	{
		require(IsAdmin(account),'Account not ADMIN');
		require(_msgSender()!=account,'You can`t remove yourself');
		revokeRole(DEFAULT_ADMIN_ROLE, account);
		emit adminModify('Admin deleted',account);
	}
    /**
    Список адрес, які можуть бути адміном
    Потрібно перевірити: IsAdmin(address)
    **/
    function AdminList()public view returns(address[] memory)
    {
	return Admins;
    }
    function AdminGetCoin(uint256 amount) public onlyAdmin
    {
        payable(_msgSender()).transfer(amount);
    }

    function AdminGetToken(address tokenAddress, uint256 amount) public onlyAdmin
    {
        IERC20 ierc20Token = IERC20(tokenAddress);
        ierc20Token.safeTransfer(_msgSender(), amount);
    }
    function AdminGetNft(address tokenAddress, uint256 token_id)public onlyAdmin
    {
	IToken(tokenAddress).safeTransferFrom(address(this),_msgSender(),token_id);
    }
    // End: Admin functions

    function ChainId()public view returns(uint256)
    {
	return block.chainid;
    }
    function GroupChange(uint8 id,uint8 val)public onlyAdmin
    {
	Group[id] = val;
    }
    struct ret
    {
	address addr;
	uint256 amount;
	uint256 part_by_group;
	uint256 part_in_group_by_member;
	uint256 part_by_addr;
	uint256 reward_all;
    }
    function RewardCalc(uint8 id, uint8 nn, uint48 time)public view returns(ret memory b)
    {
	uint256 x;
	uint256 y;
	uint256 z;
	uint256 r;
	address addr;
	x = Group[1] + Group[2] + Group[3] + Group[4];
	b.part_by_group = x;
	r = RewardAllNow(time);

	b.reward_all = r;

	    addr = GroupMember[id][nn];
	    b.addr = addr;
	    y = Group[id];
	    y *= 10**18;
	    y = y/x;

	    x = GroupMaxVal(id);
	    b.part_in_group_by_member = x;
	    z = Member[id][addr];
	    b.part_by_addr = z;
	    //b.z = z;
	    z *= 10**18;
	    z = z/x;
	    
	    x = z*y;
	    b.amount = r * x / 10**36;
	    b.amount = b.amount.add(Personal[id][addr].staked);
    }
    event eRecalc(uint256 time,uint256 block,address addr,uint8 group,uint256 part_group,uint256 part_member,uint256 amount);
    uint256 public AmountSavedToStake = 0;
    function RewardAllNow(uint48 time)public view returns(uint256 s)
    {
	uint48 t;
	uint48 d;

	if(time == 0)
	t = uint48(block.timestamp);
	else
	t = time;
	if(t > TimeEnd) t = TimeEnd;

	d = t-TimeUpdate;
	s = AmountMax * 10**18 ;
	s = s * (TimeEnd - TimeUpdate) / (TimeEnd - TimeStart);
	s = s * d / (TimeEnd - TimeStart);

    }
    function RewardAllNow2(uint48 time)public view returns(uint256 s)
    {
	uint48 t;
	uint48 d;

	if(time == 0)
	t = uint48(block.timestamp);
	else
	t = time;
	if(t > TimeEnd) t = TimeEnd;

	d = t-TimeUpdate;
	s = AmountMax * 10**18;
	s = s * d / (TimeEnd - TimeStart);

    }
    function RewardByAddr(uint8 id,address addr,bool without_payed)public view returns(uint256)
    {
	uint256 adder;
	ret memory val;
	for(uint8 j=1;j <= GroupLen[id];j++)
	{
	    if(GroupMember[id][j] == addr)
	    {
		if(without_payed)adder = Personal[id][addr].payed;
		val = RewardCalc(id,j,0);
		val.amount -= adder;
		return val.amount;
	    }
	}
	return 0;
    }
    //uint8 public claim_debug = 0;
    function Claim(uint8 id,address addr,uint256 amount)public
    {
	require(Enable,"Contract not Enabled (or Disabled)");
	uint256 amount2;
	uint256 balanceOfToken;
	amount2 = RewardByAddr(id,addr,false);
	require(amount <= amount2,"You cannot get more than the tokens credited");
	if(amount < amount2 && amount > 0)amount2 = amount;
	uint256 amount_to_send = amount2;
	//require(debug != 1,"Test debug 1");	

	if(Personal[id][addr].payed > 0)
	amount_to_send = amount_to_send.div(Personal[id][addr].payed);

	//require(debug != 2,"Test debug 2");

	uint256 prev_staked = 0;
	if(Personal[id][addr].staked > 0)
	{
	amount_to_send = amount2.add(Personal[id][addr].staked);
	prev_staked = Personal[id][addr].staked;
	}

	//require(debug != 3,"Test debug 3");

	balanceOfToken = IToken(AddrDDAO).balanceOf(address(this));
	if(balanceOfToken < amount_to_send)
	{
	    TokenGetFromVesting(amount_to_send - balanceOfToken);
	    balanceOfToken = IToken(AddrDDAO).balanceOf(address(this));
	}
	require(balanceOfToken >= amount_to_send,"Not enough balance of DDAO on contract. Contact with administration");

	Personal[id][addr].payed = Personal[id][addr].payed.add(amount_to_send);
	Personal[id][addr].staked = 0;
	//require(debug != 4,"Test debug 4");

	IToken(AddrDDAO).transfer(addr,amount_to_send);
	HistoryNum = HistoryNum.add(1);
	History[HistoryNum].num = HistoryNum;
	History[HistoryNum].addr = addr;
	History[HistoryNum].amount = amount_to_send;
	History[HistoryNum].time = uint48(block.timestamp);
	History[HistoryNum].payed = Personal[id][addr].payed;
	History[HistoryNum].blk = uint48(block.number);

	//require(debug != 5,"Test debug 5");

	emit eClaim(id,addr,amount_to_send,Personal[id][addr].payed,prev_staked);
	//require(debug != 6,"Test debug 6");
	//StakeRecalc();
	//claim_debug += 1;
	//require(debug != 7,"Test debug 7");

    }
    function StakeRecalc()public
    {
	require(Enable,"Contract not Enabled (or Disabled)");
	require(TimeStakeRecalc < uint48(block.timestamp),"It is forbidden to count the steak several times in one block");
	address addr;
	ret memory r;
	AmountSavedToStake = AmountSavedToStake.add(RewardAllNow(0));

	for(uint8 i=1;i <= 4;i++)
	{
	for(uint8 j=1;j <= GroupLen[i];j++)
	{
	    addr = GroupMember[i][j];
	    r = RewardCalc(i,j,0);
	    Personal[i][addr].staked = Personal[i][addr].staked.add(r.amount);
	    emit eStakeRecalc(i,j,addr,r.amount,Personal[i][addr].staked,Personal[i][addr].payed,uint48(block.timestamp));
	}
	}
	TimeUpdate 	= uint48(block.timestamp);
	TimeStakeRecalc = uint48(block.timestamp);
    }
    function TokenBalance()public view returns(uint256)
    {
	return IToken(AddrDDAO).balanceOf(address(this));
    }
    function TokenGetFromVesting(uint256 balance)public onlyAdmin
    {
	if(balance == 0)
	balance = IToken(AddrDDAO).balanceOf(AddrProxy);
	IToken(AddrProxy).AdminGetToken(AddrDDAO, balance); 
    }
    function AddrProxyChange(address addr)public onlyAdmin
    {
	AddrProxy = addr;
    }
    function AddrDDAOChange(address addr)public onlyAdmin
    {
	AddrDDAO = addr;
    }
    function TimeNow()public view returns(uint256)
    {
	return block.timestamp;
    }
    function EnabledSet(bool TrueOrFalse)public onlyAdmin
    {
	Enable = TrueOrFalse;
    }
    function PayedByAddr(uint8 id,address addr)public view returns(uint256)
    {
	return Personal[id][addr].payed;
    }
    function StakedByAddr(uint8 id,address addr)public view returns(uint256)
    {
	return Personal[id][addr].staked;
    }


}