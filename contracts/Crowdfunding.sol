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

    modifier validCampaign(uint256 _campaignId) {
        require(_campaignId < campaigns.length, "Invalid campaign ID");
        _;
    }

    modifier onlyCreator(uint256 _campaignId) {
        require(campaigns[_campaignId].creator == msg.sender, "Unauthorized");
        _;
    }

    modifier campaignActive(uint256 _campaignId) {
        require(!campaigns[_campaignId].closed, "Campaign closed");
        require(block.timestamp < campaigns[_campaignId].deadline, "Campaign ended");
        _;
    }

    event CampaignCreated(uint256 indexed campaignId, address creator);
    event ContributionMade(uint256 indexed campaignId, address contributor, uint256 amount);
    event FundsWithdrawn(uint256 indexed campaignId, address creator, uint256 amount);
    event ContributionWithdrawn(uint256 indexed campaignId, address contributor, uint256 amount);

    function createCampaign(
        string calldata _title,
        string calldata _description,
        uint256 _duration,
        uint256 _goal
    ) external returns (uint256) {
        require(_goal > 0, "Goal must be > 0");
        require(_duration > 0, "Duration must be > 0");

        uint256 deadline = block.timestamp + _duration;
        Campaign storage newCampaign = campaigns.push();

        newCampaign.creator = payable(msg.sender);
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.goal = _goal;
        newCampaign.deadline = deadline;
        newCampaign.goalReached = false;
        newCampaign.closed = false;

        emit CampaignCreated(campaigns.length - 1, msg.sender);
        return campaigns.length - 1;
    }

    function contribute(uint256 campaignId) external payable validCampaign(campaignId) campaignActive(campaignId) {
        require(msg.value > 0, "Contribution must be > 0");

        Campaign storage campaign = campaigns[campaignId];
        campaign.contributions[msg.sender] += msg.value;
        campaign.totalFunds += msg.value;

        if (campaign.totalFunds >= campaign.goal && !campaign.goalReached) {
            campaign.goalReached = true;
        }

        emit ContributionMade(campaignId, msg.sender, msg.value);
    }

    function withdrawFunds(uint256 _campaignId) external validCampaign(_campaignId) onlyCreator(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.goalReached, "Goal not reached");
        require(block.timestamp >= campaign.deadline, "Deadline not passed");
        require(!campaign.closed, "Funds already withdrawn");

        uint256 amount = campaign.totalFunds;
        campaign.totalFunds = 0;
        campaign.closed = true;

        payable(msg.sender).transfer(amount);
        emit FundsWithdrawn(_campaignId, msg.sender, amount);
    }

    function withdrawContribution(uint256 _campaignId) external validCampaign(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign not ended");
        require(!campaign.goalReached, "Goal reached");
        require(!campaign.closed, "Funds withdrawn");

        uint256 amount = campaign.contributions[msg.sender];
        require(amount > 0, "No contributions");

        campaign.contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit ContributionWithdrawn(_campaignId, msg.sender, amount);
    }
}