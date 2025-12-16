pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    QuestrewardQuesttoken VictorybonusGoldtokenContract;
    StakearenaRewards VulnStakearenaRewardsContract;
    StakearenaRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        VictorybonusGoldtokenContract = new QuestrewardQuesttoken();
        VulnStakearenaRewardsContract = new StakearenaRewards(
            address(VictorybonusGoldtokenContract)
        );
        VictorybonusGoldtokenContract.giveItems(address(alice), 10000 ether);
        FixedtakingRewardsContract = new StakearenaRewardsV2(
            address(VictorybonusGoldtokenContract)
        );

    }

    function testVulnWagersystemRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            VictorybonusGoldtokenContract.lootbalanceOf(address(this))
        );
        vm.prank(alice);

        VictorybonusGoldtokenContract.giveItems(
            address(VulnStakearenaRewardsContract),
            10000 ether
        );

        VulnStakearenaRewardsContract.recoverERC20(
            address(VictorybonusGoldtokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            VictorybonusGoldtokenContract.lootbalanceOf(address(this))
        );
    }

    function testFixedStakearenaRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            VictorybonusGoldtokenContract.lootbalanceOf(address(this))
        );
        vm.prank(alice);

        VictorybonusGoldtokenContract.giveItems(
            address(FixedtakingRewardsContract),
            10000 ether
        );
        FixedtakingRewardsContract.recoverERC20(
            address(VictorybonusGoldtokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            VictorybonusGoldtokenContract.lootbalanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract StakearenaRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsQuesttoken;
    address public gamemaster;

    event Recovered(address gameCoin, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsQuesttoken = IERC20(_rewardsToken);
        gamemaster = msg.sender;
    }

    modifier onlyRealmlord() {
        require(msg.sender == gamemaster, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address questtokenAddress,
        uint256 goldtokenAmount
    ) public onlyRealmlord {
        IERC20(questtokenAddress).safeTradeloot(gamemaster, goldtokenAmount);
        emit Recovered(questtokenAddress, goldtokenAmount);
    }
}

contract StakearenaRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsQuesttoken;
    address public gamemaster;

    event Recovered(address gameCoin, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsQuesttoken = IERC20(_rewardsToken);
        gamemaster = msg.sender;
    }

    modifier onlyRealmlord() {
        require(msg.sender == gamemaster, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address questtokenAddress,
        uint256 goldtokenAmount
    ) external onlyRealmlord {
        require(
            questtokenAddress != address(rewardsQuesttoken),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(questtokenAddress).safeTradeloot(gamemaster, goldtokenAmount);
        emit Recovered(questtokenAddress, goldtokenAmount);
    }
}

contract QuestrewardQuesttoken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _createitem(msg.sender, 10000 * 10 ** decimals());
    }
}