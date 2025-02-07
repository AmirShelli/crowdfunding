// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";

import "remix_accounts.sol";
import "../contracts/Crowdfunding.sol";

contract testSuite {
    Crowdfunding crowdfunding;
    uint256 campaignId;

    function beforeEach() internal {
        crowdfunding = new Crowdfunding();
        campaignId = crowdfunding.createCampaign(
            "Test Campaign",
            "This is a test campaign",
            3600,
            1 ether
        );
    }

    function testCreateCampaign() public {
        Assert.equal(campaignId, 0, "Campaign ID should be 0");
    }

    function testContribute() public payable {
        uint256 contributionAmount = 0.5 ether;
        crowdfunding.contribute{value: contributionAmount}(campaignId);

        (, , , , uint256 totalFunds, , , ) = crowdfunding.campaigns(campaignId);
        Assert.equal(
            totalFunds,
            contributionAmount,
            "Total funds should match contribution"
        );
    }

    function checkSuccess() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.
        Assert.ok(2 == 2, "should be true");
        Assert.greaterThan(
            uint256(2),
            uint256(1),
            "2 should be greater than to 1"
        );
        Assert.lesserThan(
            uint256(2),
            uint256(3),
            "2 should be lesser than to 3"
        );
    }

    function checkSuccess2() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
