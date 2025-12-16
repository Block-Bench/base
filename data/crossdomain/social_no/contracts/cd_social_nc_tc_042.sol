pragma solidity ^0.8.0;

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function reputationOf(address socialProfile) external view returns (uint256);

    function permitTransfer(address spender, uint256 amount) external returns (bool);
}

enum KarmatokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address karmaToken;
    uint256 amount;
    uint256 end;
    KarmatokenLockup reputationtokenLockup;
    bytes32 root;
}

struct RedeemreputationLockup {
    address socialtokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address socialtokenLocker;
    uint256 amount;
    uint256 reputationMultiplier;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyClaimkarmaCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        RedeemreputationLockup memory claimkarmaLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.socialtokenLocker != address(0)) {
            (bool success, ) = donation.socialtokenLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.karmaToken,
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