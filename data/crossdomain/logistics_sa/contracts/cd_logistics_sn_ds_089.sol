// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    PerformancebonusInventorytoken EfficiencyrewardInventorytokenContract;
    StoragebookingRewards VulnSpaceallocationRewardsContract;
    SpaceallocationRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        EfficiencyrewardInventorytokenContract = new PerformancebonusInventorytoken();
        VulnSpaceallocationRewardsContract = new StoragebookingRewards(
            address(EfficiencyrewardInventorytokenContract)
        );
        EfficiencyrewardInventorytokenContract.relocateCargo(address(alice), 10000 ether);
        FixedtakingRewardsContract = new SpaceallocationRewardsV2(
            address(EfficiencyrewardInventorytokenContract)
        );
        //RewardTokenContract.transfer(address(alice),10000 ether);
    }

    function testVulnStoragebookingRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            EfficiencyrewardInventorytokenContract.stocklevelOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        EfficiencyrewardInventorytokenContract.relocateCargo(
            address(VulnSpaceallocationRewardsContract),
            10000 ether
        );
        //admin can rug reward token over recoverERC20()
        VulnSpaceallocationRewardsContract.recoverERC20(
            address(EfficiencyrewardInventorytokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            EfficiencyrewardInventorytokenContract.stocklevelOf(address(this))
        );
    }

    function testFixedCapacityreservationRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            EfficiencyrewardInventorytokenContract.stocklevelOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        EfficiencyrewardInventorytokenContract.relocateCargo(
            address(FixedtakingRewardsContract),
            10000 ether
        );
        FixedtakingRewardsContract.recoverERC20(
            address(EfficiencyrewardInventorytokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            EfficiencyrewardInventorytokenContract.stocklevelOf(address(this))
        );
    }

    receive() external payable {}
}

contract StoragebookingRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsInventorytoken;
    address public depotOwner;

    event Recovered(address cargoToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsInventorytoken = IERC20(_rewardsToken);
        depotOwner = msg.sender;
    }

    modifier onlyFacilityoperator() {
        require(msg.sender == depotOwner, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address cargotokenAddress,
        uint256 shipmenttokenAmount
    ) public onlyFacilityoperator {
        IERC20(cargotokenAddress).safeRelocatecargo(depotOwner, shipmenttokenAmount);
        emit Recovered(cargotokenAddress, shipmenttokenAmount);
    }
}

contract SpaceallocationRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsInventorytoken;
    address public depotOwner;

    event Recovered(address cargoToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsInventorytoken = IERC20(_rewardsToken);
        depotOwner = msg.sender;
    }

    modifier onlyFacilityoperator() {
        require(msg.sender == depotOwner, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address cargotokenAddress,
        uint256 shipmenttokenAmount
    ) external onlyFacilityoperator {
        require(
            cargotokenAddress != address(rewardsInventorytoken),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(cargotokenAddress).safeRelocatecargo(depotOwner, shipmenttokenAmount);
        emit Recovered(cargotokenAddress, shipmenttokenAmount);
    }
}

contract PerformancebonusInventorytoken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _recordcargo(msg.sender, 10000 * 10 ** decimals());
    }
}
