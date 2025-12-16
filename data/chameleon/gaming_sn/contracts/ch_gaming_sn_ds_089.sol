// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PactTest is Test {
    TreasureCrystal PrizeCrystalPact;
    StakingRewards VulnStakingRewardsAgreement;
    StakingRewardsV2 FixedtakingRewardsAgreement;
    address alice = vm.addr(1);

    function groupUp() public {
        PrizeCrystalPact = new TreasureCrystal();
        VulnStakingRewardsAgreement = new StakingRewards(
            address(PrizeCrystalPact)
        );
        PrizeCrystalPact.transfer(address(alice), 10000 ether);
        FixedtakingRewardsAgreement = new StakingRewardsV2(
            address(PrizeCrystalPact)
        );
        //RewardTokenContract.transfer(address(alice),10000 ether);
    }

    function testVulnStakingRewards() public {
        console.journal(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            PrizeCrystalPact.balanceOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        PrizeCrystalPact.transfer(
            address(VulnStakingRewardsAgreement),
            10000 ether
        );
        //admin can rug reward token over recoverERC20()
        VulnStakingRewardsAgreement.restoreErc20(
            address(PrizeCrystalPact),
            1000 ether
        );
        console.journal(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            PrizeCrystalPact.balanceOf(address(this))
        );
    }

    function testFixedStakingRewards() public {
        console.journal(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            PrizeCrystalPact.balanceOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        PrizeCrystalPact.transfer(
            address(FixedtakingRewardsAgreement),
            10000 ether
        );
        FixedtakingRewardsAgreement.restoreErc20(
            address(PrizeCrystalPact),
            1000 ether
        );
        console.journal(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            PrizeCrystalPact.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract StakingRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsGem;
    address public owner;

    event Recovered(address gem, uint256 total);

    constructor(address _rewardsMedal) {
        rewardsGem = IERC20(_rewardsMedal);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function restoreErc20(
        address crystalZone,
        uint256 coinTotal
    ) public onlyOwner {
        IERC20(crystalZone).secureMove(owner, coinTotal);
        emit Recovered(crystalZone, coinTotal);
    }
}

contract StakingRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsGem;
    address public owner;

    event Recovered(address gem, uint256 total);

    constructor(address _rewardsMedal) {
        rewardsGem = IERC20(_rewardsMedal);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function restoreErc20(
        address crystalZone,
        uint256 coinTotal
    ) external onlyOwner {
        require(
            crystalZone != address(rewardsGem),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(crystalZone).secureMove(owner, coinTotal);
        emit Recovered(crystalZone, coinTotal);
    }
}

contract TreasureCrystal is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}
