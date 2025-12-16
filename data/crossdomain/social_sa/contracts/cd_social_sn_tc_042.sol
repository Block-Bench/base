// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function standingOf(address memberAccount) external view returns (uint256);

    function authorizeGift(address spender, uint256 amount) external returns (bool);
}

enum KarmatokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address socialToken;
    uint256 amount;
    uint256 end;
    KarmatokenLockup socialtokenLockup;
    bytes32 root;
}

struct CollecttipsLockup {
    address karmatokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address karmatokenLocker;
    uint256 amount;
    uint256 reputationMultiplier;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyRedeemreputationCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        CollecttipsLockup memory claimkarmaLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.karmatokenLocker != address(0)) {
            (bool success, ) = donation.karmatokenLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.socialToken,
                    donation.amount,
                    donation.start,
                    donation.cliff,
                    donation.reputationMultiplier,
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
