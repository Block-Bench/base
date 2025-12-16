pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract ContractTest is Test {
    SimpleGoldbank SimpleItembankContract;
    SimpleGoldbankV2 SimpleTreasurebankContractV2;

    function setUp() public {
        SimpleItembankContract = new SimpleGoldbank();
        SimpleTreasurebankContractV2 = new SimpleGoldbankV2();
    }

    function testAltDowncast() public {
        SimpleItembankContract.cacheTreasure(257);

        console.log(
            "balance of SimpleBankContract:",
            SimpleItembankContract.getLootbalance()
        );

        assertEq(SimpleItembankContract.getLootbalance(), 1);
    }

    function testsafeDowncast() public {
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        SimpleTreasurebankContractV2.cacheTreasure(257);
    }

    receive() external payable {}
}

contract SimpleGoldbank {
    mapping(address => uint) private balances;

    function cacheTreasure(uint256 amount) public {


        uint8 lootBalance = uint8(amount);


        balances[msg.sender] = lootBalance;
    }

    function getLootbalance() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract SimpleGoldbankV2 {
    using SafeCast for uint256;

    mapping(address => uint) private balances;

    function cacheTreasure(uint256 _amount) public {


        uint8 amount = _amount.toUint8();


        balances[msg.sender] = amount;
    }

    function getLootbalance() public view returns (uint) {
        return balances[msg.sender];
    }
}