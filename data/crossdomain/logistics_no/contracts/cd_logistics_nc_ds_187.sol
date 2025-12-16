pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract ContractTest is Test {
    SimpleInventorybank SimpleCargobankContract;
    SimpleInventorybankV2 SimpleLogisticsbankContractV2;

    function setUp() public {
        SimpleCargobankContract = new SimpleInventorybank();
        SimpleLogisticsbankContractV2 = new SimpleInventorybankV2();
    }

    function testAltDowncast() public {
        SimpleCargobankContract.receiveShipment(257);

        console.log(
            "balance of SimpleBankContract:",
            SimpleCargobankContract.getInventory()
        );

        assertEq(SimpleCargobankContract.getInventory(), 1);
    }

    function testsafeDowncast() public {
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        SimpleLogisticsbankContractV2.receiveShipment(257);
    }

    receive() external payable {}
}

contract SimpleInventorybank {
    mapping(address => uint) private balances;

    function receiveShipment(uint256 amount) public {


        uint8 inventory = uint8(amount);


        balances[msg.sender] = inventory;
    }

    function getInventory() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract SimpleInventorybankV2 {
    using SafeCast for uint256;

    mapping(address => uint) private balances;

    function receiveShipment(uint256 _amount) public {


        uint8 amount = _amount.toUint8();


        balances[msg.sender] = amount;
    }

    function getInventory() public view returns (uint) {
        return balances[msg.sender];
    }
}