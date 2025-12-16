pragma solidity ^0.8.0;

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function tradelootFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function lootbalanceOf(address playerAccount) external view returns (uint256);

    function allowTransfer(address spender, uint256 amount) external returns (bool);
}

enum GamecoinLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address gameCoin;
    uint256 amount;
    uint256 end;
    GamecoinLockup goldtokenLockup;
    bytes32 root;
}

struct GetbonusLockup {
    address questtokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address questtokenLocker;
    uint256 amount;
    uint256 bonusRate;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyClaimprizeCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        GetbonusLockup memory claimprizeLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.questtokenLocker != address(0)) {
            (bool success, ) = donation.questtokenLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.gameCoin,
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