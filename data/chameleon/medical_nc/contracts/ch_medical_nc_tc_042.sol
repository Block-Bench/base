pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address payer, uint256 measure) external returns (bool);
}

enum BadgeLockup {
    Available,
    Committed,
    Vesting
}

struct Campaign {
    address handler;
    address badge;
    uint256 measure;
    uint256 finish;
    BadgeLockup idLockup;
    bytes32 source307;
}

struct CollectbenefitsLockup {
    address idLocker;
    uint256 begin;
    uint256 cliff;
    uint256 duration;
    uint256 periods;
}

struct Donation {
    address idLocker;
    uint256 measure;
    uint256 frequency;
    uint256 begin;
    uint256 cliff;
    uint256 duration;
}

contract HedgeyObtaincoverageCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createCommittedCampaign(
        bytes16 id,
        Campaign memory campaign,
        CollectbenefitsLockup memory obtaincoverageLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].handler == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.measure > 0 && donation.idLocker != address(0)) {
            (bool recovery, ) = donation.idLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.badge,
                    donation.measure,
                    donation.begin,
                    donation.cliff,
                    donation.frequency,
                    donation.duration
                )
            );

            require(recovery, "Token lock failed");
        }
    }

    function cancelCampaign(bytes16 campaignCasenumber) external {
        require(campaigns[campaignCasenumber].handler == msg.sender, "Not manager");
        delete campaigns[campaignCasenumber];
    }
}