


// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.8.0; 

contract CrowdFundingCampaing{
    
    //@ core values
    address public campaignOwner;
    uint256 public targetAmount;
    uint256 public deadline;
    bool public isCampaignActive;

    mapping(address => uint256) public contributions;
    uint256 public totalRaised;

    event CampaignStarted(address indexed owner, uint256 targetAmount, uint256 deadline);
    event ContributionReceived(address indexed  contributior, uint256 amount);
    event CampaignFinalized(bool successful);

    modifier onlyCampaignOnwer(){
        require(msg.sender == campaignOwner, "Only the campaign owner can call this function");
        _;
    }

    constructor(uint256 _targetAmount, uint256 _durationInDays){
        campaignOwner = msg.sender;
        targetAmount = _targetAmount;
        deadline = block.timestamp + (_durationInDays * 1 days);
        isCampaignActive = true;

        emit CampaignStarted(campaignOwner, targetAmount, deadline);
    }

    // Contribute Function
    function contribute() public payable {
        require(isCampaignActive, "Campaing is not active");
        require(block.timestamp < deadline, "Campaing dealline has passed");
        require(msg.value > 0, "Contribution amount must be greater than 0");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        emit ContributionReceived(msg.sender, msg.value);
    }

    // GetContributorsBalance Function
    function getContributorsBalance() public view returns (uint256){
        return contributions[msg.sender];
    }

    // GetTotalFundRaised
    function getTotalRaised() public view returns (uint256){
        return totalRaised;
    }

    // GetCampaingStatus
    function getCampaignStatus() public view returns (bool){
        return isCampaignActive;
    }

    // WithdrawFuns
    function withdrawFunds() public onlyCampaignOnwer{
        require(!isCampaignActive, "Campaign is still active");
        require(totalRaised >= targetAmount, "Target amount not reached");

        payable (campaignOwner).transfer(totalRaised);
        totalRaised = 0;
        emit CampaignFinalized(true);
    }

    // function finalizedCampaign() public onlyCampaignOnwer{
    //     require(!isCampaignActive, "Campaign is still active");

    //     if(totalRaised >= targetAmount){
    //         require();
    //     }
    // }
    function getRefund() public{
        require(!isCampaignActive, "Campaign is still active");
        require(contributions[msg.sender] > 0, "No contribution to refund");

        uint256 refundAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }

    function getCampaignDetails() public view returns (address, uint256, uint256, bool, uint256){
        return (campaignOwner, targetAmount, deadline, isCampaignActive, totalRaised);
    }

}