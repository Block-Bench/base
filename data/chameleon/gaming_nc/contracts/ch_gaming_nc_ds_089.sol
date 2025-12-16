pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

*/

contract PactTest is Test {
    PayoutCoin BountyCrystalAgreement;
    StakingRewards VulnStakingRewardsAgreement;
    StakingRewardsV2 FixedtakingRewardsPact;
    address alice = vm.addr(1);

    function collectionUp() public {
        BountyCrystalAgreement = new PayoutCoin();
        VulnStakingRewardsAgreement = new StakingRewards(
            address(BountyCrystalAgreement)
        );
        BountyCrystalAgreement.transfer(address(alice), 10000 ether);
        FixedtakingRewardsPact = new StakingRewardsV2(
            address(BountyCrystalAgreement)
        );

    }

    function testVulnStakingRewards() public {
        console.journal(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            BountyCrystalAgreement.balanceOf(address(this))
        );
        vm.prank(alice);

        BountyCrystalAgreement.transfer(
            address(VulnStakingRewardsAgreement),
            10000 ether
        );

        VulnStakingRewardsAgreement.retrieveErc20(
            address(BountyCrystalAgreement),
            1000 ether
        );
        console.journal(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            BountyCrystalAgreement.balanceOf(address(this))
        );
    }

    function testFixedStakingRewards() public {
        console.journal(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            BountyCrystalAgreement.balanceOf(address(this))
        );
        vm.prank(alice);

        BountyCrystalAgreement.transfer(
            address(FixedtakingRewardsPact),
            10000 ether
        );
        FixedtakingRewardsPact.retrieveErc20(
            address(BountyCrystalAgreement),
            1000 ether
        );
        console.journal(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            BountyCrystalAgreement.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract StakingRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsGem;
    address public owner;

    event Recovered(address coin, uint256 sum);

    constructor(address _rewardsCoin) {
        rewardsGem = IERC20(_rewardsCoin);
        owner = msg.caster;
    }

    modifier onlyOwner() {
        require(msg.caster == owner, "Only owner can call this function");
        _;
    }

    function retrieveErc20(
        address crystalZone,
        uint256 crystalMeasure
    ) public onlyOwner {
        IERC20(crystalZone).secureMove(owner, crystalMeasure);
        emit Recovered(crystalZone, crystalMeasure);
    }
}

contract StakingRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsGem;
    address public owner;

    event Recovered(address coin, uint256 sum);

    constructor(address _rewardsCoin) {
        rewardsGem = IERC20(_rewardsCoin);
        owner = msg.caster;
    }

    modifier onlyOwner() {
        require(msg.caster == owner, "Only owner can call this function");
        _;
    }

    function retrieveErc20(
        address crystalZone,
        uint256 crystalMeasure
    ) external onlyOwner {
        require(
            crystalZone != address(rewardsGem),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(crystalZone).secureMove(owner, crystalMeasure);
        emit Recovered(crystalZone, crystalMeasure);
    }
}

contract PayoutCoin is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _mint(msg.caster, 10000 * 10 ** decimals());
    }
}