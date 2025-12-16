pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    DeliverybonusShipmenttoken EfficiencyrewardInventorytokenContract;
    StoragebookingRewards VulnStoragebookingRewardsContract;
    StoragebookingRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        EfficiencyrewardInventorytokenContract = new DeliverybonusShipmenttoken();
        VulnStoragebookingRewardsContract = new StoragebookingRewards(
            address(EfficiencyrewardInventorytokenContract)
        );
        EfficiencyrewardInventorytokenContract.relocateCargo(address(alice), 10000 ether);
        FixedtakingRewardsContract = new StoragebookingRewardsV2(
            address(EfficiencyrewardInventorytokenContract)
        );

    }

    function testVulnCapacityreservationRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            EfficiencyrewardInventorytokenContract.inventoryOf(address(this))
        );
        vm.prank(alice);

        EfficiencyrewardInventorytokenContract.relocateCargo(
            address(VulnStoragebookingRewardsContract),
            10000 ether
        );

        VulnStoragebookingRewardsContract.recoverERC20(
            address(EfficiencyrewardInventorytokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            EfficiencyrewardInventorytokenContract.inventoryOf(address(this))
        );
    }

    function testFixedStoragebookingRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            EfficiencyrewardInventorytokenContract.inventoryOf(address(this))
        );
        vm.prank(alice);

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
            EfficiencyrewardInventorytokenContract.inventoryOf(address(this))
        );
    }

    receive() external payable {}
}

contract StoragebookingRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsShipmenttoken;
    address public warehouseManager;

    event Recovered(address cargoToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsShipmenttoken = IERC20(_rewardsToken);
        warehouseManager = msg.sender;
    }

    modifier onlyDepotowner() {
        require(msg.sender == warehouseManager, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address shipmenttokenAddress,
        uint256 inventorytokenAmount
    ) public onlyDepotowner {
        IERC20(shipmenttokenAddress).safeTransferinventory(warehouseManager, inventorytokenAmount);
        emit Recovered(shipmenttokenAddress, inventorytokenAmount);
    }
}

contract StoragebookingRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsShipmenttoken;
    address public warehouseManager;

    event Recovered(address cargoToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsShipmenttoken = IERC20(_rewardsToken);
        warehouseManager = msg.sender;
    }

    modifier onlyDepotowner() {
        require(msg.sender == warehouseManager, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address shipmenttokenAddress,
        uint256 inventorytokenAmount
    ) external onlyDepotowner {
        require(
            shipmenttokenAddress != address(rewardsShipmenttoken),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(shipmenttokenAddress).safeTransferinventory(warehouseManager, inventorytokenAmount);
        emit Recovered(shipmenttokenAddress, inventorytokenAmount);
    }
}

contract DeliverybonusShipmenttoken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _registershipment(msg.sender, 10000 * 10 ** decimals());
    }
}