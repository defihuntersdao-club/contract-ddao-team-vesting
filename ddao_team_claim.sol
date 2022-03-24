// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

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

    uint48  constant public TimeStart = 1646092800; // 1 MAR 2022
    uint256 constant public AmountMax = 1680000;
    uint48  constant public TimeEnd = TimeStart + 24 * 86400*30;

    address public AddrDDAO = 0x90F3edc7D5298918F7BB51694134b07356F7d0C7;
    address public AddrProxy = 0x2E7bEC36f8642Cc3df83C19470bE089A5FAF98Fa;
    uint48  public TimeUpdate;

    mapping(uint8 => uint8)public Group;

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
    }

    struct personal
    {
	uint8 id;
	uint256 staked;
	uint256 payed;
    }
    mapping(uint8 => mapping(address => personal))public Personal;

    event eStakeRecalc(uint8 id,address addr,uint256 amount,uint256 staked,uint48 time);
    event eClaim(uint8 id,address addr,uint256 amount,uint256 payed);

	mapping(uint8 => mapping(uint8 => address))public GroupMember;
	mapping(uint8 => address[]) GroupMemberAddr;
	mapping(uint8 => uint8)public GroupLen;
	function GroupMemberAdd(uint8 id,address addr,uint8 val)public onlyAdmin
	{
	    require(GroupLen[id]<256,"The group is full");
	    GroupLen[id]++;
	    Member[id][addr] = val;
	    GroupMember[id][GroupLen[id]] = addr;
	    GroupMemberAddr[id].push(addr);
	    Personal[id][addr].id = GroupLen[id];
	    Personal[id][addr].staked = 0;
	    Personal[id][addr].payed = 0;
	}
	function GroupMemeberChange(uint8 id,address addr,uint8 val)public onlyAdmin
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
	    _setupRole(DEFAULT_ADMIN_ROLE, 0x208b02f98d36983982eA9c0cdC6B3208e0f198A3);
	    //AdminAdd(_msgSender());

		GroupMemberAdd(1,0xa5B32272f2FE16d402Fe6Da4EDfF84cD6f8e4AA0,10);
		GroupMemberAdd(1,0xe44b45E38E5Fe6d39c0370E55eB2453E25F7c3C5,10);
		GroupMemberAdd(1,0xF11Ffb4848e8a2E05eAb2cAfb02108277b56d0B7,10);
		GroupMemberAdd(1,0xB2207c34dE61f3018576cb637Fa90DAE0425D916,10);

		GroupMemberAdd(2,0xe44b45E38E5Fe6d39c0370E55eB2453E25F7c3C5,45);

		GroupMemberAdd(3,0xa5B32272f2FE16d402Fe6Da4EDfF84cD6f8e4AA0,10);

		GroupMemberAdd(4,0x97299ea1C42b3fA53b805e0E92b1e05500519762,45);
		GroupMemberAdd(4,0x9134408d47239DD81402723B8f0444cf66B82e5D,45);
    
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
    function RewardCalc(uint8 id,uint8 nn,uint48 time)public view returns(ret memory b)
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
    }
    event eRecalc(uint256 time,uint256 block,address addr,uint8 group,uint256 part_group,uint256 part_member,uint256 amount);
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
	s = AmountMax * 10**18;
	s = s * d / (TimeEnd - TimeStart);

    }
    function RewardByAddr(uint8 id,address addr)public view returns(uint256)
    {
	ret memory val;
	for(uint8 j=1;j <= GroupLen[id];j++)
	{
	    if(GroupMember[id][j] == addr)
	    {
		val = RewardCalc(id,j,0);
		return val.amount;
	    }
	}
	return 0;
    }
    function Claim(uint8 id,address addr,uint256 amount)public
    {
	uint256 amount2;
	uint256 balanceOfToken;
	amount2 = RewardByAddr(id,addr);
	require(amount <= amount2,"You cannot get more than the tokens credited");
	if(amount < amount2 && amount > 0)amount2 = amount;
	uint256 amount_to_send;
	amount_to_send = amount2.sub(Personal[id][addr].payed);
	balanceOfToken = IToken(AddrDDAO).balanceOf(address(this));
	if(balanceOfToken < amount_to_send)
	{
	    TokenGetFromVesting(amount_to_send - balanceOfToken);
	    balanceOfToken = IToken(AddrDDAO).balanceOf(address(this));
	}
	require(balanceOfToken >= amount_to_send,"Not enough balance of DDAO on contract. Contact with administration");
	Personal[id][addr].payed = Personal[id][addr].payed.add(amount_to_send);
	IToken(AddrDDAO).transfer(addr,amount_to_send);
	HistoryNum = HistoryNum.add(1);
	History[HistoryNum].num = HistoryNum;
	History[HistoryNum].addr = addr;
	History[HistoryNum].amount = amount_to_send;
	History[HistoryNum].time = uint48(block.timestamp);
	History[HistoryNum].payed = Personal[id][addr].payed;
	emit eClaim(id,addr,amount_to_send,Personal[id][addr].payed);
    }
    function StakeRecalc()public
    {
	address addr;
	ret memory r;
	for(uint8 i=1;i <= 4;i++)
	{
	for(uint8 j=1;j <= GroupLen[i];j++)
	{
	    addr = GroupMember[i][j];
	    r = RewardCalc(i,j,0);
	    Personal[i][addr].staked = Personal[i][addr].staked.add(r.amount);
	    emit eStakeRecalc(i,addr,r.amount,Personal[i][addr].staked,uint48(block.timestamp));
	}
	}
	TimeUpdate = uint48(block.timestamp);
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
}