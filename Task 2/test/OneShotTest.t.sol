// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, Vm} from "../lib/forge-std/src/Test.sol";
import {RapBattle} from "../src/RapBattle.sol";
import {OneShot} from "../src/OneShot.sol";
import {Streets} from "../src/Streets.sol";
import {Credibility} from "../src/CredToken.sol";
import {IOneShot} from "../src/interfaces/IOneShot.sol";

contract RapBattleTest is Test {
    RapBattle rapBattle;
    OneShot oneShot;
    Streets streets;
    Credibility cred;
    IOneShot.RapperStats stats;
    address user;
    address challenger;

    function setUp() public {
        oneShot = new OneShot();
        cred = new Credibility();
        streets = new Streets(address(oneShot), address(cred));
        rapBattle = new RapBattle(address(oneShot), address(cred));
        user = makeAddr("Alice");
        challenger = makeAddr("Slim Shady");

        oneShot.setStreetsContract(address(streets));
        cred.setStreetsContract(address(streets));
    }

    // mint rapper modifier
    modifier mintRapper() {
        vm.prank(user);
        oneShot.mintRapper();
        _;
    }

    modifier twoSkilledRappers() {
        vm.startPrank(user);
        oneShot.mintRapper();
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        vm.stopPrank();

        vm.startPrank(challenger);
        oneShot.mintRapper();
        oneShot.approve(address(streets), 1);
        streets.stake(1);
        vm.stopPrank();

        vm.warp(4 days + 1);

        vm.startPrank(user);
        streets.unstake(0);
        vm.stopPrank();
        vm.startPrank(challenger);
        streets.unstake(1);
        vm.stopPrank();
        _;
    }

    // Test that a user can mint a rapper
    function testMintRapper() public {
        address testUser = makeAddr("Bob");
        vm.prank(testUser);
        oneShot.mintRapper();
        assert(oneShot.ownerOf(0) == testUser);
    }

    // Test that only the streets contract can update rapper stats
    function testAccessControlOnUpdateRapperStats() public mintRapper {
        vm.prank(user);
        vm.expectRevert();
        oneShot.updateRapperStats(0, true, true, true, true, 0);
    }

    // Test that only owner can set streets contract
    function testAccessControlOnSetStreetsContract() public {
        vm.prank(user);
        vm.expectRevert();
        oneShot.setStreetsContract(address(streets));
    }

    // test getRapperStats
    function testGetRapperStats() public mintRapper {
        stats = oneShot.getRapperStats(0);

        assert(stats.weakKnees == true);
        assert(stats.heavyArms == true);
        assert(stats.spaghettiSweater == true);
        assert(stats.calmAndReady == false);
        assert(stats.battlesWon == 0);
    }

    // Test getNexTokenId
    function testGetNextTokenId() public mintRapper {
        assert(oneShot.getNextTokenId() == 1);
    }

    // Test that a user can stake a rapper
    function testStake() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        (, address owner) = streets.stakes(0);
        assert(owner == address(user));
    }

    // Test that a user can unstake a rapper
    function testUnstake() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        (, address owner) = streets.stakes(0);
        assert(owner == address(user));
        streets.unstake(0);
        (, address newOwner) = streets.stakes(0);
        assert(newOwner == address(0));
    }

    // Test cred is minted when a rapper is staked for at least one day
    function testCredMintedWhenRapperStakedForOneDay() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        vm.stopPrank();
        vm.warp(1 days + 1);
        vm.startPrank(user);
        streets.unstake(0);

        assert(cred.balanceOf(address(user)) == 1);
    }

    // Test rapper stats are updated when a rapper is staked for at least one day
    function testRapperStatsUpdatedWhenRapperStakedForOneDay() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        vm.stopPrank();
        vm.warp(4 days + 1);
        vm.startPrank(user);
        streets.unstake(0);

        stats = oneShot.getRapperStats(0);
        assert(stats.weakKnees == false);
        assert(stats.heavyArms == false);
        assert(stats.spaghettiSweater == false);
        assert(stats.calmAndReady == true);
        assert(stats.battlesWon == 0);
    }

    // Test that a user can go on stage
    function testGoOnStage() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), 0);
        rapBattle.goOnStageOrBattle(0, 0);
        address defender = rapBattle.defender();
        assert(defender == address(user));
    }

    // Test that rapper is transferred to rap battle contract when going on stage
    function testRapperTransferredToRapBattle() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), 0);
        rapBattle.goOnStageOrBattle(0, 0);
        address owner = oneShot.ownerOf(0);
        assert(owner == address(rapBattle));
    }

    // test that a user can go on stage and battle
    function testGoOnStageOrBattle() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), 0);
        rapBattle.goOnStageOrBattle(0, 0);
        vm.stopPrank();
        vm.startPrank(challenger);
        oneShot.mintRapper();
        oneShot.approve(address(rapBattle), 1);
        rapBattle.goOnStageOrBattle(1, 0);
    }

    // Test that bets must match when going on stage or battling
    function testBetsMustMatch() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), 0);
        rapBattle.goOnStageOrBattle(0, 0);
        vm.stopPrank();
        vm.startPrank(challenger);
        oneShot.mintRapper();
        oneShot.approve(address(rapBattle), 1);
        vm.expectRevert();
        rapBattle.goOnStageOrBattle(1, 1);
    }

    // Test winner is transferred the bet amount
    function testWinnerTransferredBetAmount(uint256 randomBlock) public twoSkilledRappers {
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), 0);
        cred.approve(address(rapBattle), 3);
        console.log("User allowance before battle:", cred.allowance(user, address(rapBattle)));
        rapBattle.goOnStageOrBattle(0, 3);
        vm.stopPrank();

        vm.startPrank(challenger);
        oneShot.approve(address(rapBattle), 1);
        cred.approve(address(rapBattle), 3);
        console.log("User allowance before battle:", cred.allowance(challenger, address(rapBattle)));

        // Change the block number so we get different RNG
        vm.roll(randomBlock);
        vm.recordLogs();
        rapBattle.goOnStageOrBattle(1, 3);
        vm.stopPrank();

        Vm.Log[] memory entries = vm.getRecordedLogs();
        // Convert the event bytes32 objects -> address
        address winner = address(uint160(uint256(entries[0].topics[2])));
        assert(cred.balanceOf(winner) == 7);
    }

    // Test that the defender's NFT is returned to them
    function testDefendersNftReturned() public twoSkilledRappers {
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), 0);
        cred.approve(address(rapBattle), 10);
        rapBattle.goOnStageOrBattle(0, 3);
        vm.stopPrank();

        vm.startPrank(challenger);
        oneShot.approve(address(rapBattle), 1);
        cred.approve(address(rapBattle), 10);

        rapBattle.goOnStageOrBattle(1, 3);
        vm.stopPrank();

        assert(oneShot.ownerOf(0) == address(user));
    }

    // test getRapperSkill
    function testGetRapperSkill() public mintRapper {
        uint256 skill = rapBattle.getRapperSkill(0);
        assert(skill == 50);
    }

    // test getRapperSkill with updated stats
    function testGetRapperSkillAfterStake() public twoSkilledRappers {
        uint256 skill = rapBattle.getRapperSkill(0);
        assert(skill == 75);
    }

    // test onERC721Received in Streets.sol when staked
    function testOnERC721Received() public mintRapper {
        vm.startPrank(user);
        oneShot.approve(address(streets), 0);
        streets.stake(0);
        assert(
            streets.onERC721Received(address(0), user, 0, "")
                == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
        );
    }
}
