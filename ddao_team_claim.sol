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
//    using SafeMath  for uint32;
    using SafeERC20 for IERC20;

    event eClaim(uint8 grp,address addr,uint256 amount,uint256 payed);

    uint48  constant public TimeStart   = 1646092800; // 1 MAR 2022
    uint256 constant public AmountMax   = 1680000;
    uint48  constant public TimeEnd     = TimeStart + 24 * 86400*30;

    address public AddrDDAO = 0x90F3edc7D5298918F7BB51694134b07356F7d0C7;

    mapping(uint8 => uint8)public Group;
    mapping(uint8 => uint8)public GroupLen;
    mapping(uint8 => address[])public MemberAddr;
    mapping(uint8 => uint8[])public MemberKoef;
    mapping(uint8 => mapping(address => uint8))	public MemberNum;

    mapping(uint8 => mapping(address => uint256))public MemberEpoch;

    mapping(uint8 => mapping(address => uint256))public Payed;

    uint48  immutable public TimeDeploy;
    uint256 immutable public BlockDeploy;

    uint256 public EpochCount = 0;

    mapping(uint8 => mapping(address => uint8))public Member;

    bool public UpdateNeed = false;

    bool public Enable = true;

    mapping(uint256 => epoch) public Epoch;

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


    struct epoch
    {
	uint32 num;
	bool closed;
	uint48 time_start;
	uint48 time_end;
//	uint256 amount;
	mapping(uint8 => uint8[]) arr;
//	uint8[] arr1;
//	uint8[] arr2;
//	uint8[] arr3;
//	uint8[] arr4;
	uint8[] sum;
//	uint8 sum2;
//	uint8 sum3;
//	uint8 sum4;
	uint8[] grp;
//	uint8 grp2;
//	uint8 grp3;
//	uint8 grp4;
	uint8 grp_sum;

    }

        constructor()
        {
        TimeDeploy      = uint48(block.timestamp);
        BlockDeploy     = block.number;
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
            AdminAdd(0x208b02f98d36983982eA9c0cdC6B3208e0f198A3);

            if( block.chainid == 80001)
            {
                AddrDDAO = 0xE1F0e40846218bF2CACfEd40c00bE218F54C49f7;
            }

            if( block.chainid == 3)
            {
                AddrDDAO = 0x086F80a0ebC2a92bBb3e4476b30f67D058a4c26A;
            }

            GroupMemberAdd(1,0x330eC7c6AfC3cF19511Ad4041e598B235D44862f,90);
            GroupMemberAdd(1,0x57266f25439B60A94e4a47Cbc1bF1A2A6C119109, 5);
            GroupMemberAdd(1,0x5BB72943dFd6201897d163D06DaEC4c4557Ab25c, 5);

            GroupMemberAdd(2,0xB7E0cC3b51AFD812C1C4aeFd437D3c5daC0D4efF,45);

            GroupMemberAdd(3,0x0954409a3cfA81F05fE7421f3Aa162146a28b848,10);

	    GroupMemberAdd(4,0xeA10DD05CF0A12AB1BDBd202FA8707D3BFd08737,45);
	    GroupMemberAdd(4,0xD54201a17a0b00F5726a38EE6bcCae1371631Dd6,45);

//	    GroupMemberChange(4,0xD54201a17a0b00F5726a38EE6bcCae1371631Dd6,5);
	    EpochNext();
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

    function GroupMemberAdd(uint8 grp,address addr, uint8 koef)public onlyAdmin
    {
        require(GroupLen[grp]<256,"The group is full");
	require(MemberEpoch[grp][addr]==0,"Member already exist");
        GroupLen[grp]++;
        MemberKoef[grp].push(koef);
        MemberAddr[grp].push(addr);
        MemberNum[grp][addr] 		= GroupLen[grp];
	UpdateNeed = true;
	MemberEpoch[grp][addr] = EpochCount.add(1);
	Payed[grp][addr] = 0;
    }
    function GroupMemberChange(uint8 grp,address addr, uint8 koef)public onlyAdmin
    {
	uint8 i;
	i = MemberNum[grp][addr]-1;
	MemberKoef[grp][i] = koef;
	UpdateNeed = true;
    }
    function GroupKoefShow(uint8 grp)public view returns(uint8[] memory)
    {
	return MemberKoef[grp];
    }
    function GroupKoefSum(uint8 grp)public view returns(uint8 sum)
    {
	for(uint8 i = 0;i < MemberKoef[grp].length;i++)
	{
	    sum += MemberKoef[grp][i];
	}
    }
    function EpochNext()public onlyAdmin
    {
	uint48 now_time = uint48(block.timestamp);
	require(UpdateNeed,"No members change. No need next epoch.");
	require(now_time < TimeEnd,"The contract has already expired.");
	if(EpochCount >0)
	{
	    Epoch[EpochCount].closed = true;
	    Epoch[EpochCount].time_end = now_time;
	}
	EpochCount = EpochCount.add(1);

	if(EpochCount == 1)
	    Epoch[EpochCount].time_start = TimeStart;
	else
	    Epoch[EpochCount].time_start = now_time+1;

	    Epoch[EpochCount].time_end = TimeEnd;

	    Epoch[EpochCount].arr[1] = GroupKoefShow(1);
	    Epoch[EpochCount].arr[2] = GroupKoefShow(2);
	    Epoch[EpochCount].arr[3] = GroupKoefShow(3);
	    Epoch[EpochCount].arr[4] = GroupKoefShow(4);

	    Epoch[EpochCount].sum.push(GroupKoefSum(1));
	    Epoch[EpochCount].sum.push(GroupKoefSum(2));
	    Epoch[EpochCount].sum.push(GroupKoefSum(3));
	    Epoch[EpochCount].sum.push(GroupKoefSum(4));

	    Epoch[EpochCount].grp.push(Group[1]);
	    Epoch[EpochCount].grp.push(Group[2]);
	    Epoch[EpochCount].grp.push(Group[3]);
	    Epoch[EpochCount].grp.push(Group[4]);
	    Epoch[EpochCount].grp_sum = Epoch[EpochCount].grp[0] + Epoch[EpochCount].grp[1] + Epoch[EpochCount].grp[2] + Epoch[EpochCount].grp[3];
	    Epoch[EpochCount].closed = false;

	UpdateNeed = false;
    }

    struct reward_calc
    {
	uint48 interval;
	uint48 time_end;

	uint256 part_time;
	uint256 part_grp;
	uint256 part_user;

	uint256 amount_all;
	uint256 amount_grp;
	uint256 amount_usr;
	
    }

    function RewardCalc(uint8 grp, address addr, uint48 time)public view returns(uint256 amount)
    {
//	uint256 amount ;
	amount = 0;
	reward_calc memory temp;
	bool flag = false;
	uint8 num = MemberNum[grp][addr];
	if(time == 0)time = uint48(block.timestamp);

	for(uint256 i = 1;i <= EpochCount;i++)
	{
	    if(MemberEpoch[grp][addr] > i)continue;

	    if(!flag)
	    {

	    if(Epoch[i].time_start > time)flag = true;
	    else
	    {


		if(Epoch[i].time_end > time)flag = true;

		if(time < Epoch[i].time_end)temp.time_end = time;
		else temp.time_end = Epoch[i].time_end;
		
		temp.interval = temp.time_end - Epoch[i].time_start;
//		amount = temp.interval;
//		amount = PartTime(temp.interval);

		temp.part_time = PartTime(temp.interval);
//		amount = temp.part_time;

		temp.part_grp  = PartAmount(Epoch[i].grp[grp-1],Epoch[i].grp_sum);
		temp.part_user = PartAmount(Epoch[i].arr[grp][num-1],Epoch[i].sum[grp-1]);

		temp.amount_all = AmountMax * temp.part_time / 10**8;
		temp.amount_grp = temp.amount_all * temp.part_grp / 10**8;
		temp.amount_usr = temp.amount_grp * temp.part_user / 10**8;
		temp.amount_usr /= 10**12;

		amount = amount.add(temp.amount_usr);

	    }

	    }

	}

    if(amount == 0)amount = 2;

    }
    function PartTime(uint48 interval)public pure returns(uint256 out)
    {
	uint256 sum = TimeEnd - TimeStart;
	uint256 i = uint256(interval) * 10**18;
	out = i / sum;
    } 
    function PartAmount(uint8 val, uint8 sum)public pure returns(uint256 out)
    {
	uint256 i = uint256(val) * 10**18;
	out = i / uint256(sum);
    }
    function EnabledSet(bool TrueOrFalse)public onlyAdmin
    {
        Enable = TrueOrFalse;
    }
    function Claim(uint8 grp,address addr,uint256 amount)public
    {
	require(Enable,"Contract not Enabled (or Disabled)");
	uint256 amount_to_send = RewardCalc(grp,addr,0);
	amount_to_send = amount_to_send.sub(Payed[grp][addr]);
        require(amount <= amount_to_send,"You cannot get more than the tokens credited");
        if(amount < amount_to_send && amount > 0)amount_to_send = amount;

        uint256 balanceOfToken = IToken(AddrDDAO).balanceOf(address(this));
	require(balanceOfToken >= amount_to_send,"Not enough balance of DDAO on contract. Contact with administration");

	Payed[grp][addr] = Payed[grp][addr].add(amount_to_send);
        IToken(AddrDDAO).transfer(addr,amount_to_send);
        HistoryNum = HistoryNum.add(1);
        History[HistoryNum].num    = HistoryNum;
        History[HistoryNum].addr   = addr;
        History[HistoryNum].amount = amount_to_send;
        History[HistoryNum].time   = uint48(block.timestamp);
        History[HistoryNum].blk    = block.number;
        History[HistoryNum].payed  = Payed[grp][addr];

        emit eClaim(grp,addr,amount_to_send,Payed[grp][addr]);
    }
    function ClaimAmount(uint8 grp, address addr)public view returns(uint256 amount)
    {
	amount = RewardCalc(grp,addr,0) - Payed[grp][addr];
    }
    
}