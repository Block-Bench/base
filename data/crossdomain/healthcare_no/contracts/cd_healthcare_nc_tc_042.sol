pragma solidity ^0.8.0;

interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function coverageOf(address patientAccount) external view returns (uint256);

    function validateClaim(address spender, uint256 amount) external returns (bool);
}

enum HealthtokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address healthToken;
    uint256 amount;
    uint256 end;
    HealthtokenLockup coveragetokenLockup;
    bytes32 root;
}

struct SubmitclaimLockup {
    address benefittokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address benefittokenLocker;
    uint256 amount;
    uint256 benefitRatio;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyRequestbenefitCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        SubmitclaimLockup memory requestbenefitLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.benefittokenLocker != address(0)) {
            (bool success, ) = donation.benefittokenLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.healthToken,
                    donation.amount,
                    donation.start,
                    donation.cliff,
                    donation.benefitRatio,
                    donation.period
                )
            );

            require(success, "Token lock failed");
        }
    }

    function cancelCampaign(bytes16 campaignId) external {
        require(campaigns[campaignId].manager == msg.sender, "Not manager");
        delete campaigns[campaignId];
    }
}