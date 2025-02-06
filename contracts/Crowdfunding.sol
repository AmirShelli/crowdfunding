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
        mapping(address => uint256) funder;
    }

    Campaign[] public campaigns;

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _duration,
        uint256 _goal
    ) public {
        uint256 _deadline = block.timestamp + _duration;

        Campaign storage newCampaign = campaigns.push();
        newCampaign.creator = payable(msg.sender);
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.goal = _goal;
        newCampaign.deadline = _deadline;
        newCampaign.goalReached = false;
    }

    function contribute(uint256 campaignId) public payable {
        campaigns[campaignId].funder[msg.sender] += msg.value;
        campaigns[campaignId].totalFunds += msg.value; //won't it get duplicated here? does the contributor lose its money or???

        if (
            campaigns[campaignId].totalFunds >= campaigns[campaignId].goal &&
            !campaigns[campaignId].goalReached
        ) {
            campaigns[campaignId].goalReached = true;
            //send event on goal reached
        }

        //send event to update funds
    }

    function withdrawFunds(uint256 _campaignId) public payable {
        //add modifier isOwner

        require(campaigns[_campaignId].goalReached, "Goal not reached yet!");
        campaigns[_campaignId].creator.transfer(
            campaigns[_campaignId].totalFunds
        );
        campaigns[_campaignId].totalFunds = 0;
        
    }

    function withdrawContributions(uint256 _campaignId) public payable {
        require(
            block.timestamp >= campaigns[_campaignId].deadline,
            "Campaign not ended"
        );
        require(
            !campaigns[_campaignId].goalReached,
            "Goal reached, no refunds"
        );

        uint256 amount = campaigns[_campaignId].funder[msg.sender];
        payable(msg.sender).transfer(amount);
    }
}
