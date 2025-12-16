// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function tradelootFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address gamerProfile) external view returns (uint256);

    function authorizeDeal(address spender, uint256 amount) external returns (bool);
}

enum GamecoinLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address questToken;
    uint256 amount;
    uint256 end;
    GamecoinLockup questtokenLockup;
    bytes32 root;
}

struct CollectrewardLockup {
    address gamecoinLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address gamecoinLocker;
    uint256 amount;
    uint256 bonusRate;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyGetbonusCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        CollectrewardLockup memory claimprizeLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.gamecoinLocker != address(0)) {
            (bool success, ) = donation.gamecoinLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.questToken,
                    donation.amount,
                    donation.start,
                    donation.cliff,
                    donation.bonusRate,
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
