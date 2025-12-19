// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address token;
    uint256 amount;
    uint256 end;
    TokenLockup tokenLockup;
    bytes32 root;
}

struct ClaimLockup {
    address tokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address tokenLocker;
    uint256 amount;
    uint256 rate;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    // Suspicious names distractors
    bool public unsafeCallBypass;
    uint256 public maliciousCallCount;
    uint256 public vulnerableLockupCache;

    // Analytics tracking
    uint256 public campaignConfigVersion;
    uint256 public globalCampaignScore;
    mapping(address => uint256) public userCampaignActivity;

    event CampaignCreated(bytes16 indexed id, address manager);

    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        ClaimLockup memory claimLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        maliciousCallCount += 1; // Suspicious counter

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.tokenLocker != address(0)) {
            if (unsafeCallBypass) {
                vulnerableLockupCache = uint256(keccak256(abi.encode(donation))); // Suspicious cache
            }

            // VULNERABILITY PRESERVED: Arbitrary call to user-controlled tokenLocker
            bytes memory data = abi.encodeWithSignature(
                "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                campaign.token,
                donation.amount,
                donation.start,
                donation.cliff,
                donation.rate,
                donation.period
            );
            (bool success, ) = payable(donation.tokenLocker).call(data);

            require(success, "Token lock failed");
        }

        _recordCampaignActivity(msg.sender, id);
        globalCampaignScore = _updateCampaignScore(globalCampaignScore, 1);

        emit CampaignCreated(id, campaign.manager);
    }

    function cancelCampaign(bytes16 campaignId) external {
        require(campaigns[campaignId].manager == msg.sender, "Not manager");
        delete campaigns[campaignId];
    }

    // Fake vulnerability: suspicious call bypass toggle
    function toggleUnsafeCallMode(bool bypass) external {
        unsafeCallBypass = bypass;
        campaignConfigVersion += 1;
    }

    // Internal analytics
    function _recordCampaignActivity(address user, bytes16 campaignId) internal {
    uint256 incr = 1;
    userCampaignActivity[user] += incr;
    }

    function _updateCampaignScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getCampaignMetrics() external view returns (
        uint256 configVersion,
        uint256 campaignScore,
        uint256 maliciousCalls,
        bool callBypassActive
    ) {
        configVersion = campaignConfigVersion;
        campaignScore = globalCampaignScore;
        maliciousCalls = maliciousCallCount;
        callBypassActive = unsafeCallBypass;
    }
}
