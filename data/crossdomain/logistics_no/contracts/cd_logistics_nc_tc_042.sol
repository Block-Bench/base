pragma solidity ^0.8.0;

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function transferinventoryFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function inventoryOf(address shipperAccount) external view returns (uint256);

    function approveDispatch(address spender, uint256 amount) external returns (bool);
}

enum CargotokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address cargoToken;
    uint256 amount;
    uint256 end;
    CargotokenLockup inventorytokenLockup;
    bytes32 root;
}

struct ClaimgoodsLockup {
    address shipmenttokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address shipmenttokenLocker;
    uint256 amount;
    uint256 turnoverRate;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyReceivedeliveryCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        ClaimgoodsLockup memory receivedeliveryLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.shipmenttokenLocker != address(0)) {
            (bool success, ) = donation.shipmenttokenLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.cargoToken,
                    donation.amount,
                    donation.start,
                    donation.cliff,
                    donation.turnoverRate,
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