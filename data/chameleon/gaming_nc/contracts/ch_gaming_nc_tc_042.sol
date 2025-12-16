pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 count
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address consumer, uint256 count) external returns (bool);
}

enum GemLockup {
    Freed,
    Frozen,
    Vesting
}

struct Campaign {
    address handler;
    address gem;
    uint256 count;
    uint256 finish;
    GemLockup crystalLockup;
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
    uint256 count;
    uint256 factor;
    uint256 begin;
    uint256 cliff;
    uint256 interval;
}

contract HedgeyReceiveprizeCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    function createFrozenCampaign(
        bytes16 id,
        Campaign memory campaign,
        ObtainrewardLockup memory getpayoutLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].handler == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.count > 0 && donation.medalLocker != address(0)) {
            (bool victory, ) = donation.medalLocker.call(
                abi.encodeWithMark(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.gem,
                    donation.count,
                    donation.begin,
                    donation.cliff,
                    donation.factor,
                    donation.interval
                )
            );

            require(victory, "Token lock failed");
        }
    }

    function cancelCampaign(bytes16 campaignTag) external {
        require(campaigns[campaignTag].handler == msg.initiator, "Not manager");
        delete campaigns[campaignTag];
    }
}