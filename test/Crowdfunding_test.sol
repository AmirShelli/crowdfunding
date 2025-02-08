// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";

import "remix_accounts.sol";
import "../contracts/Crowdfunding.sol";

contract CrowdfundingTest {
    Crowdfunding cf;

    function beforeAll() public {
        cf = new Crowdfunding();
    }

    function testCreateCampaign() public {
        uint256 campaignId = cf.createCampaign("Test", "Desc", 1, 1 ether);
        Assert.equal(campaignId, 0, "Campaign ID should be 0");
        (address payable creator, , , , , , , ) = cf.campaigns(0);
        Assert.equal(creator, address(this), "Creator should be test contract");
    }

    function testInvalidCampaignParameters() public {
        try cf.createCampaign("Invalid", "Desc", 0, 1 ether) {
            Assert.ok(false, "Should fail with zero duration");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Duration must be > 0", "Expected duration error");
        }
        try cf.createCampaign("Invalid", "Desc", 1, 0) {
            Assert.ok(false, "Should fail with zero goal");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Goal must be > 0", "Expected goal error");
        }
    }

    function testContribute() public payable {
        uint256 campaignId = cf.createCampaign("Test2", "Desc2", 3600, 2 ether);
        (, , , , uint256 beforeTotal, , , ) = cf.campaigns(campaignId);
        uint256 contribution = 0.5 ether;
        cf.contribute{value: contribution}(campaignId);
        (, , , , uint256 afterTotal, , , ) = cf.campaigns(campaignId);
        Assert.equal(afterTotal, beforeTotal + contribution, "Total funds increased");
    }

    function testZeroContribution() public {
        uint256 campaignId = cf.createCampaign("Test3", "Desc3", 3600, 1 ether);
        try cf.contribute{value: 0}(campaignId) {
            Assert.ok(false, "Zero contribution should fail");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Contribution must be > 0", "Expected zero contribution error");
        }
    }

    function testWithdrawFundsRevertBeforeDeadline() public {
        uint256 campaignId = cf.createCampaign("Test4", "Desc4", 3600, 1 ether);
        cf.contribute{value: 1 ether}(campaignId);
        try cf.withdrawFunds(campaignId) {
            Assert.ok(false, "Withdraw before deadline should fail");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Deadline not passed", "Expected deadline not passed error");
        }
    }

    function testWithdrawContributionRevertBeforeDeadline() public {
        uint256 campaignId = cf.createCampaign("Test5", "Desc5", 3600, 1 ether);
        cf.contribute{value: 0.3 ether}(campaignId);
        try cf.withdrawContribution(campaignId) {
            Assert.ok(false, "Withdraw contribution before deadline should fail");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Campaign not ended", "Expected campaign not ended error");
        }
    }

    function testWithdrawFundsUnauthorized() public {
        uint256 campaignId = cf.createCampaign("Test6", "Desc6", 1, 1 ether);
        cf.contribute{value: 1 ether}(campaignId);
        NonCreator nc = new NonCreator(cf);
        bool success = nc.attemptWithdraw(campaignId);
        Assert.equal(success, false, "Non-creator withdrawal should fail");
    }
}

contract NonCreator {
    Crowdfunding cf;
    constructor(Crowdfunding _cf) {
        cf = _cf;
    }
    function attemptWithdraw(uint256 campaignId) public returns (bool) {
        try cf.withdrawFunds(campaignId) {
            return true;
        } catch {
            return false;
        }
    }
}