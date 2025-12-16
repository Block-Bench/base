// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function transferinventoryFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goodsonhandOf(address cargoProfile) external view returns (uint256);

    function authorizeShipment(address spender, uint256 amount) external returns (bool);
}

enum ShipmenttokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address shipmentToken;
    uint256 amount;
    uint256 end;
    ShipmenttokenLockup cargotokenLockup;
    bytes32 root;
}

struct CollectshipmentLockup {
    address inventorytokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address inventorytokenLocker;
    uint256 amount;
    uint256 throughputRate;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyReceivedeliveryCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        CollectshipmentLockup memory pickupcargoLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.inventorytokenLocker != address(0)) {
            (bool success, ) = donation.inventorytokenLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.shipmentToken,
                    donation.amount,
                    donation.start,
                    donation.cliff,
                    donation.throughputRate,
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
