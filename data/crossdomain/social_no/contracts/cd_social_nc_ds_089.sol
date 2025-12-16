pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    KarmabonusSocialtoken CommunityrewardReputationtokenContract;
    BackingcontractRewards VulnBackingcontractRewardsContract;
    BackingcontractRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        CommunityrewardReputationtokenContract = new KarmabonusSocialtoken();
        VulnBackingcontractRewardsContract = new BackingcontractRewards(
            address(CommunityrewardReputationtokenContract)
        );
        CommunityrewardReputationtokenContract.shareKarma(address(alice), 10000 ether);
        FixedtakingRewardsContract = new BackingcontractRewardsV2(
            address(CommunityrewardReputationtokenContract)
        );

    }

    function testVulnEndorsementsystemRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            CommunityrewardReputationtokenContract.reputationOf(address(this))
        );
        vm.prank(alice);

        CommunityrewardReputationtokenContract.shareKarma(
            address(VulnBackingcontractRewardsContract),
            10000 ether
        );

        VulnBackingcontractRewardsContract.recoverERC20(
            address(CommunityrewardReputationtokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            CommunityrewardReputationtokenContract.reputationOf(address(this))
        );
    }

    function testFixedBackingcontractRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            CommunityrewardReputationtokenContract.reputationOf(address(this))
        );
        vm.prank(alice);

        CommunityrewardReputationtokenContract.shareKarma(
            address(FixedtakingRewardsContract),
            10000 ether
        );
        FixedtakingRewardsContract.recoverERC20(
            address(CommunityrewardReputationtokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            CommunityrewardReputationtokenContract.reputationOf(address(this))
        );
    }

    receive() external payable {}
}

contract BackingcontractRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsSocialtoken;
    address public moderator;

    event Recovered(address karmaToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsSocialtoken = IERC20(_rewardsToken);
        moderator = msg.sender;
    }

    modifier onlyFounder() {
        require(msg.sender == moderator, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address socialtokenAddress,
        uint256 reputationtokenAmount
    ) public onlyFounder {
        IERC20(socialtokenAddress).safeGivecredit(moderator, reputationtokenAmount);
        emit Recovered(socialtokenAddress, reputationtokenAmount);
    }
}

contract BackingcontractRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsSocialtoken;
    address public moderator;

    event Recovered(address karmaToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsSocialtoken = IERC20(_rewardsToken);
        moderator = msg.sender;
    }

    modifier onlyFounder() {
        require(msg.sender == moderator, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address socialtokenAddress,
        uint256 reputationtokenAmount
    ) external onlyFounder {
        require(
            socialtokenAddress != address(rewardsSocialtoken),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(socialtokenAddress).safeGivecredit(moderator, reputationtokenAmount);
        emit Recovered(socialtokenAddress, reputationtokenAmount);
    }
}

contract KarmabonusSocialtoken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _earnkarma(msg.sender, 10000 * 10 ** decimals());
    }
}