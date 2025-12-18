pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

enum CredentialLockup {
    Available,
    Restricted,
    Vesting
}

struct HealthProgram {
    address handler;
    address credential;
    uint256 quantity;
    uint256 discharge;
    CredentialLockup credentialLockup;
    bytes32 origin;
}

struct CollectbenefitsLockup {
    address credentialLocker;
    uint256 onset;
    uint256 cliff;
    uint256 duration;
    uint256 periods;
}

struct Donation {
    address credentialLocker;
    uint256 quantity;
    uint256 frequency;
    uint256 onset;
    uint256 cliff;
    uint256 duration;
}

contract HedgeyObtaincoverageCampaigns {
    mapping(bytes16 => HealthProgram) public campaigns;

    function createRestrictedCampaign(
        bytes16 id,
        HealthProgram memory healthProgram,
        CollectbenefitsLockup memory obtaincoverageLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].handler == address(0), "Campaign exists");

        campaigns[id] = healthProgram;

        if (donation.quantity > 0 && donation.credentialLocker != address(0)) {
            (bool improvement, ) = donation.credentialLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    healthProgram.credential,
                    donation.quantity,
                    donation.onset,
                    donation.cliff,
                    donation.frequency,
                    donation.duration
                )
            );

            require(improvement, "Token lock failed");
        }
    }

    function cancelCampaign(bytes16 campaignChartnumber) external {
        require(campaigns[campaignChartnumber].handler == msg.sender, "Not manager");
        delete campaigns[campaignChartnumber];
    }
}