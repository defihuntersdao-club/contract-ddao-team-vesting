const DDAOTeamClaim = artifacts.require("DDAOTeamClaim");
const ERC20Base = artifacts.require("ERC20Base");
const ERC721Base = artifacts.require("ERC721Base");

const Reverter = require("./helpers/reverter");
const { setCurrentTime } = require("./helpers/ganacheTimeTraveler");
const truffleAssert = require("truffle-assertions");
const { assert } = require("chai");
const BigNumber = require("bignumber.js");

function toBN(number) {
  return new BigNumber(number);
}

async function getBlockTimestamp() {
  const latest = toBN(await web3.eth.getBlockNumber());
  return (await web3.eth.getBlock(latest)).timestamp;
}

const wei = web3.utils.toWei;
const fromWei = web3.utils.fromWei;

contract("DDAOTeamClaim", async (accounts) => {
  const reverter = new Reverter(web3);

  let ddaoTeamClaim;
  let addrProxy;
  let addrDdao;
  let baseToken;
  let nftERC721Mock;

  const MAIN = accounts[0];

  let USER1_G1;
  let USER2_G1;
  let USER3_G1;

  let USER4_G2;

  let USER5_G3;

  let USER6_G4;
  let USER7_G4;

  const NOTHING = accounts[9];

  const TIME_START = 1646092800; // 1 MAR.
  const MAX_AMOUNT = 1680000;
  const TIME_END = TIME_START + 24 * 86400 * 30;

  before("setup", async () => {
    ddaoTeamClaim = await DDAOTeamClaim.new();

    tokenDDAOMock = await ERC20Base.new(MAX_AMOUNT);
    nftERC721Mock = await ERC721Base.new();

    USER1_G1 = (await ddaoTeamClaim.GroupMemberShow(1))[0];
    USER2_G1 = (await ddaoTeamClaim.GroupMemberShow(1))[1];
    USER3_G1 = (await ddaoTeamClaim.GroupMemberShow(1))[2];

    USER4_G2 = (await ddaoTeamClaim.GroupMemberShow(2))[0];
    USER5_G3 = (await ddaoTeamClaim.GroupMemberShow(3))[0];

    USER6_G4 = (await ddaoTeamClaim.GroupMemberShow(4))[0];
    USER7_G4 = (await ddaoTeamClaim.GroupMemberShow(4))[1];

    await ddaoTeamClaim.changeAddrDDAO(tokenDDAOMock.address);

    await reverter.snapshot();
  });

  afterEach("revert", reverter.revert);

  describe("constructor", async () => {
    it("Should be set up initial variables", async () => {
      assert.equal(await ddaoTeamClaim.Group(1), 10);
      assert.equal(await ddaoTeamClaim.Group(2), 10);
      assert.equal(await ddaoTeamClaim.Group(3), 30);
      assert.equal(await ddaoTeamClaim.Group(4), 50);

      // Nothing to get
      assert.equal(await ddaoTeamClaim.Group(5), 0);

      assert.equal(await ddaoTeamClaim.GroupLen(1), 3);
      assert.equal(await ddaoTeamClaim.GroupLen(2), 1);
      assert.equal(await ddaoTeamClaim.GroupLen(3), 1);
      assert.equal(await ddaoTeamClaim.GroupLen(4), 2);
    });
  });

  describe("GroupMemberAdd", async () => {
    it("Should be created new group and added member", async () => {
      await ddaoTeamClaim.GroupMemberAdd(5, NOTHING, 10);
      assert.equal(await ddaoTeamClaim.GroupLen(5), 1);
    });
    // it("Should be failed dou to the value out-of-bounds", async () => {
    //     await truffleAssert.reverts(ddaoTeamClaim.GroupMemberAdd(256, NOTHING, 0), 'The group is full');
    // });
  });

  describe("GroupMemberChange", async () => {
    it("Should be updated member koef", async () => {
      await ddaoTeamClaim.GroupMemberChange(1, USER1_G1, 100);
      assert.equal(await ddaoTeamClaim.UpdateNeed(), true);
    });
  });

  describe("GroupMemberShow", async () => {
    it("Should be returned the address of member", async () => {
      await ddaoTeamClaim.GroupMemberAdd(5, NOTHING, 10);
      assert.equal((await ddaoTeamClaim.GroupMemberShow(5)).length, 1);
    });
  });

  describe("GroupMaxVal", async () => {
    it("Should be took into account new member and new member group koef", async () => {
      const koef = 5;
      await ddaoTeamClaim.GroupMemberAdd(1, NOTHING, koef);
      assert.equal((await ddaoTeamClaim.MemberKoef(1, 1)).toNumber(), 5);
    });
  });

  describe("IsAdmin", async () => {
    it("Should be granted _msSender by role", async () => {
      assert.equal(await ddaoTeamClaim.IsAdmin(MAIN), true);
    });
    it("Should be granted 0x208b02f98d36983982eA9c0cdC6B3208e0f198A3 by role", async () => {
      assert.equal(await ddaoTeamClaim.IsAdmin("0x208b02f98d36983982eA9c0cdC6B3208e0f198A3"), true);
    });
  });

  describe("AdminAdd", async () => {
    it("Should be reverted as account already is ADMIN", async () => {
      await truffleAssert.reverts(ddaoTeamClaim.AdminAdd(MAIN), "Account already ADMIN");
    });
    it("Should be granted NOTHING as ADMIN", async () => {
      await ddaoTeamClaim.AdminAdd(NOTHING);
      assert.equal(await ddaoTeamClaim.IsAdmin(NOTHING), true);
    });
  });

  describe("AdminDel", async () => {
    it("Should be reverted as account NOTHING in not ADMIN", async () => {
      await truffleAssert.reverts(ddaoTeamClaim.AdminDel(NOTHING), "Account not ADMIN");
    });
    it("Should be remoted account 0x208b02f98d36983982eA9c0cdC6B3208e0f198A3 from ADMIN", async () => {
      await ddaoTeamClaim.AdminDel("0x208b02f98d36983982eA9c0cdC6B3208e0f198A3");
      assert.equal(await ddaoTeamClaim.IsAdmin("0x208b02f98d36983982eA9c0cdC6B3208e0f198A3"), false);
    });
  });

  describe("AdminList", async () => {
    it("Should return all Admins", async () => {
      assert.equal((await ddaoTeamClaim.AdminList()).length, 2);
    });
  });

  describe("AdminGetCoin", async () => {
    it("Should be reverted as NOTHING is not admin", async function () {
      const reason = "Access for Admin's only";

      await truffleAssert.reverts(ddaoTeamClaim.AdminGetCoin(0, { from: NOTHING }), reason);
    });
    it("Should be reverted as a fallback isn't exist", async function() {
        await truffleAssert.reverts(ddaoTeamClaim.AdminGetCoin('1'), "VM Exception while processing transaction: revert");
    });
  });

  describe("AdminGetToken", async () => {
    it("Should be sent token to admin", async () => {
      await tokenDDAOMock.transfer(ddaoTeamClaim.address, wei(`${MAX_AMOUNT}`));

      const amount = wei('1000000');

      await ddaoTeamClaim.AdminGetToken(tokenDDAOMock.address, amount);
      assert.equal((await tokenDDAOMock.balanceOf(MAIN)).toString(), amount);
    });
  });

  describe("AdminGetNft", async () => {
    it("Should be transferred nft to admin", async () => {
      const tx = await nftERC721Mock.awardItem(ddaoTeamClaim.address, "https://..");
      assert.equal((await nftERC721Mock.balanceOf(ddaoTeamClaim.address)).toString(), "1");

      const tokenId = tx.logs[0].args[2].toNumber();
      await ddaoTeamClaim.AdminGetNft(nftERC721Mock.address, tokenId);
      assert.equal((await nftERC721Mock.balanceOf(ddaoTeamClaim.address)).toString(), "0");
    });
  });

  describe("ChainId", async () => {
    it("Should return chain id", async () => {
      assert.equal((await ddaoTeamClaim.ChainId()).toNumber(), 1);
      // assert.equal((await ddaoTeamClaim.ChainId()).toNumber(), 80001); // polygon_testnet = 80001
    });
  });

  describe("RewardAllNow", async () => {
    it("Should return all rewards", async () => {
      // console.log(await ddaoTeamClaim.RewardAllNow(0))
    });
  });

  describe("RewardByAddr", async () => {});

  describe("Claim ZERO balance on contract", async () => {
    it("Reverts if DDAOTeamClaim doesnt have DDAO balance", async () => {
      const reason = "Not enough balance of DDAO on contract. Contact with administration.";

      await truffleAssert.reverts(ddaoTeamClaim.Claim(USER1_G1), reason);
    });
  });

  describe("Claim with balance on contract", async () => {
    beforeEach("setup", async () => {
      await tokenDDAOMock.transfer(ddaoTeamClaim.address, wei(`${MAX_AMOUNT}`));
    });

    it("Should able to claim from Group[1], Group[2], Group[3], Group[4]", async () => {
      setCurrentTime(TIME_END);

      await ddaoTeamClaim.Claim(USER1_G1);
      assert.equal((fromWei(await tokenDDAOMock.balanceOf(USER1_G1))).toString(), '151200');

      await ddaoTeamClaim.Claim(USER2_G1);
      assert.equal((fromWei(await tokenDDAOMock.balanceOf(USER2_G1))).toString(), '8400');

      await ddaoTeamClaim.Claim(USER3_G1);
      assert.equal((fromWei(await tokenDDAOMock.balanceOf(USER3_G1))).toString(), '8400');

      await ddaoTeamClaim.Claim(USER4_G2);
      assert.equal((fromWei(await tokenDDAOMock.balanceOf(USER4_G2))).toString(), '168000');

      await ddaoTeamClaim.Claim(USER5_G3);
      assert.equal((fromWei(await tokenDDAOMock.balanceOf(USER5_G3))).toString(), '504000');

      await ddaoTeamClaim.Claim(USER6_G4);
      assert.equal((fromWei(await tokenDDAOMock.balanceOf(USER6_G4))).toString(), '420000');

      await ddaoTeamClaim.Claim(USER7_G4);
      assert.equal((fromWei(await tokenDDAOMock.balanceOf(USER7_G4))).toString(), '420000');
    });

    it("Reverts if try claim more than credited", async () => {
      const reason = "You cannot get more than the tokens credited";

      await truffleAssert.reverts(ddaoTeamClaim.Claim(1, USER1_G1, MAX_AMOUNT), reason);
      await truffleAssert.reverts(ddaoTeamClaim.Claim(1, USER2_G1, MAX_AMOUNT), reason);
      await truffleAssert.reverts(ddaoTeamClaim.Claim(1, USER3_G1, MAX_AMOUNT), reason);
      await truffleAssert.reverts(ddaoTeamClaim.Claim(2, USER4_G2, MAX_AMOUNT), reason);
      await truffleAssert.reverts(ddaoTeamClaim.Claim(3, USER5_G3, MAX_AMOUNT), reason);
      await truffleAssert.reverts(ddaoTeamClaim.Claim(4, USER6_G4, MAX_AMOUNT), reason);
      await truffleAssert.reverts(ddaoTeamClaim.Claim(4, USER7_G4, MAX_AMOUNT), reason);
    });

    it("Reverts if contract is not enable", async () => {
      const reason = "Contract not Enabled (or Disabled)";

      await ddaoTeamClaim.EnabledSet(false);
      await truffleAssert.reverts(ddaoTeamClaim.Claim(1, USER1_G1, MAX_AMOUNT), reason);
    })
  });

  describe("RewardCalc", async () => {
    beforeEach("setup", async () => {
      await tokenDDAOMock.transfer(ddaoTeamClaim.address, wei(`${MAX_AMOUNT}`));
    });

    it("Should be calculated properly user reward", async () => {
      setCurrentTime(1648985090);

      await ddaoTeamClaim.Claim(USER1_G1);
      assert.closeTo(
        toBN(fromWei(await tokenDDAOMock.balanceOf(USER1_G1))).toNumber(),
        toBN('7030').toNumber(),
        toBN('0.2').toNumber()
      )
    })
  });

  describe("EpochNext", async () => {
    it("Should change epoch", async () => {
      await ddaoTeamClaim.GroupMemberAdd(5, NOTHING, 10);

      await ddaoTeamClaim.EpochNext();
      assert.equal(await ddaoTeamClaim.EpochCount(), 2);
    })
  })

  describe("EpochViewSum", async () => {
    it("Should show right epoch sum", async () => {
      assert.equal((await ddaoTeamClaim.EpochViewSum(1, 1)).toString(), '100');
    })
  })

  describe("EpochViewArr", async () => {
    it("Should return group member by epoch", async () => {
      assert.equal((await ddaoTeamClaim.EpochViewArr(1, 1)).toString(), '90,5,5')
    })
  })

  describe("balanceOf", async () => {
    it("Should return balance which could be claimed", async () => {
      setCurrentTime(TIME_END);

      assert.equal((fromWei(await ddaoTeamClaim.balanceOf(USER1_G1))).toString(), '151200')
    })
  })

  describe("ClaimAmount", async () => {
    it("Should return amount to claim", async () => {
      setCurrentTime(TIME_END);

      assert.equal((fromWei(await ddaoTeamClaim.ClaimAmount(USER1_G1))).toString(), '151200')
    })
  })

  describe("EpochViewGrp", async () => {
    it("Should return group rait", async () => {
      assert.equal((await ddaoTeamClaim.EpochViewGrp(1, 1)).toString(), '10')
      assert.equal((await ddaoTeamClaim.EpochViewGrp(1, 2)).toString(), '10')
      assert.equal((await ddaoTeamClaim.EpochViewGrp(1, 3)).toString(), '30')
      assert.equal((await ddaoTeamClaim.EpochViewGrp(1, 4)).toString(), '50')
    })
  })

  describe("PartAmount", async () => {
    it("Should return part by amount", async () => {
      assert.equal((await ddaoTeamClaim.PartAmount(1, 1)).toString(), '1000000000000000000')
    })
  })

  describe("Claimed", async () => {
    beforeEach("setup", async () => {
      await tokenDDAOMock.transfer(ddaoTeamClaim.address, wei(`${MAX_AMOUNT}`));
    });

    it("Should return claimed", async () => {
      setCurrentTime(TIME_END);

      assert.equal((await ddaoTeamClaim.Claimed(USER1_G1)).toString(), '0')
      
      await ddaoTeamClaim.Claim(USER1_G1);

      assert.equal((fromWei(await ddaoTeamClaim.Claimed(USER1_G1))).toString(), '151200')
    })
  })
});
