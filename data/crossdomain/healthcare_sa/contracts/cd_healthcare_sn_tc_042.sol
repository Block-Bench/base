// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowanceOf(address memberRecord) external view returns (uint256);

    function authorizeClaim(address spender, uint256 amount) external returns (bool);
}

enum BenefittokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address benefitToken;
    uint256 amount;
    uint256 end;
    BenefittokenLockup healthtokenLockup;
    bytes32 root;
}

struct FileclaimLockup {
    address coveragetokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address coveragetokenLocker;
    uint256 amount;
    uint256 reimbursementRate;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyRequestbenefitCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        FileclaimLockup memory requestpayoutLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.coveragetokenLocker != address(0)) {
            (bool success, ) = donation.coveragetokenLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.benefitToken,
                    donation.amount,
                    donation.start,
                    donation.cliff,
                    donation.reimbursementRate,
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
