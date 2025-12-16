// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address payer, uint256 quantity) external returns (bool);
}

enum CredentialLockup {
    Available,
    Reserved,
    Vesting
}

struct Campaign {
    address coordinator;
    address id;
    uint256 quantity;
    uint256 finish;
    CredentialLockup credentialLockup;
    bytes32 origin;
}

struct ReceivetreatmentLockup {
    address credentialLocker;
    uint256 begin;
    uint256 cliff;
    uint256 duration;
    uint256 periods;
}

struct Donation {
    address credentialLocker;
    uint256 quantity;
    uint256 factor;
    uint256 begin;
    uint256 cliff;
    uint256 duration;
}

contract HedgeyCollectbenefitsCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createCommittedCampaign(
        bytes16 id,
        Campaign memory campaign,
        ReceivetreatmentLockup memory getcareLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].coordinator == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.quantity > 0 && donation.credentialLocker != address(0)) {
            (bool recovery, ) = donation.credentialLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.id,
                    donation.quantity,
                    donation.begin,
                    donation.cliff,
                    donation.factor,
                    donation.duration
                )
            );

            require(recovery, "Token lock failed");
        }
    }

    function cancelCampaign(bytes16 campaignChartnumber) external {
        require(campaigns[campaignChartnumber].coordinator == msg.sender, "Not manager");
        delete campaigns[campaignChartnumber];
    }
}
