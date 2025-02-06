// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Crowdfunding {
    struct Campaign {
        address payable creator;
        string title;
        string description;
        uint256 goal;
        uint256 totalFunds;
        uint256 deadline;
        bool goalReached;
        bool closed;
        mapping(address => uint256) contributions;
    }

    Campaign[] public campaigns;

    // Modifier: Campaign must exist
    modifier validCampaign(uint256 _campaignId) {
        require(_campaignId < campaigns.length, "Invalid campaign ID");
        _;
    }

    // Modifier: Only the campaign creator can call
    modifier onlyCreator(uint256 _campaignId) {
        require(campaigns[_campaignId].creator == msg.sender, "Unauthorized");
        _;
    }

    // Modifier: Campaign must be active (not closed and deadline not passed)
    modifier campaignActive(uint256 _campaignId) {
        require(!campaigns[_campaignId].closed, "Campaign closed");
        require(
            block.timestamp < campaigns[_campaignId].deadline,
            "Campaign ended"
        );
        _;
    }

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _duration,
        uint256 _goal
    ) public {
        require(_goal > 0, "Goal must be > 0");
        require(_duration > 0, "Duration must be > 0");

        uint256 _deadline = block.timestamp + _duration;

        Campaign storage newCampaign = campaigns.push();
        newCampaign.creator = payable(msg.sender);
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.goal = _goal;
        newCampaign.deadline = _deadline;
        newCampaign.goalReached = false;
    }

    function contribute(uint256 _campaignId)
        public
        payable
        validCampaign(_campaignId)
        campaignActive(_campaignId)
    {
        require(msg.value > 0, "Contribution must be > 0");

        campaigns[_campaignId].contributions[msg.sender] += msg.value;
        campaigns[_campaignId].totalFunds += msg.value;

        if (
            campaigns[_campaignId].totalFunds >= campaigns[_campaignId].goal &&
            !campaigns[_campaignId].goalReached
        ) {
            campaigns[_campaignId].goalReached = true;
            //send event on goal reached
        }

        //send event to update funds
    }

    function withdrawFunds(uint256 _campaignId)
        public
        payable
        validCampaign(_campaignId)
        onlyCreator(_campaignId)
    {
        require(campaigns[_campaignId].goalReached, "Goal not reached");
        require(
            block.timestamp >= campaigns[_campaignId].deadline,
            "Deadline not passed"
        );
        require(!campaigns[_campaignId].closed, "Already withdrawn");

        uint256 amount = campaigns[_campaignId].totalFunds;
        campaigns[_campaignId].totalFunds = 0;
        campaigns[_campaignId].closed = false;
        campaigns[_campaignId].creator.transfer(amount);
    }

    function withdrawContributions(uint256 _campaignId)
        public
        payable
        validCampaign(_campaignId)
        campaignActive(_campaignId)
    {
        require(
            block.timestamp >= campaigns[_campaignId].deadline,
            "Campaign not ended"
        );

        uint256 amount = campaigns[_campaignId].contributions[msg.sender];
        require(amount > 0, "No contributions to withdraw");

        campaigns[_campaignId].contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
