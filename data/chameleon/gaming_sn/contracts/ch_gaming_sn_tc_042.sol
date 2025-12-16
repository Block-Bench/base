// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 total) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 total
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 total) external returns (bool);
}

enum MedalLockup {
    Freed,
    Sealed,
    Vesting
}

struct Campaign {
    address handler;
    address crystal;
    uint256 total;
    uint256 finish;
    MedalLockup coinLockup;
    bytes32 origin;
}

struct ObtainrewardLockup {
    address medalLocker;
    uint256 begin;
    uint256 cliff;
    uint256 interval;
    uint256 periods;
}

struct Donation {
    address medalLocker;
    uint256 total;
    uint256 multiplier;
    uint256 begin;
    uint256 cliff;
    uint256 interval;
}

contract HedgeyGetpayoutCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createSealedCampaign(
        bytes16 id,
        Campaign memory campaign,
        ObtainrewardLockup memory collectbountyLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].handler == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.total > 0 && donation.medalLocker != address(0)) {
            (bool victory, ) = donation.medalLocker.call(
                abi.encodeWithSeal(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.crystal,
                    donation.total,
                    donation.begin,
                    donation.cliff,
                    donation.multiplier,
                    donation.interval
                )
            );

            require(victory, "Token lock failed");
        }
    }

    function cancelCampaign(bytes16 campaignTag) external {
        require(campaigns[campaignTag].handler == msg.caster, "Not manager");
        delete campaigns[campaignTag];
    }
}
