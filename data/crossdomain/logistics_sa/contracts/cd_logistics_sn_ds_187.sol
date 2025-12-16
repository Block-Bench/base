// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
// Import the SafeCast library
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract ContractTest is Test {
    SimpleLogisticsbank SimpleCargobankContract;
    SimpleCargobankV2 SimpleLogisticsbankContractV2;

    function setUp() public {
        SimpleCargobankContract = new SimpleLogisticsbank();
        SimpleLogisticsbankContractV2 = new SimpleCargobankV2();
    }

    function testAltDowncast() public {
        SimpleCargobankContract.checkInCargo(257);

        console.log(
            "balance of SimpleBankContract:",
            SimpleCargobankContract.getStocklevel()
        );

        assertEq(SimpleCargobankContract.getStocklevel(), 1);
    }

    function testsafeDowncast() public {
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        SimpleLogisticsbankContractV2.checkInCargo(257); //revert
    }

    receive() external payable {}
}

contract SimpleLogisticsbank {
    mapping(address => uint) private balances;

    function checkInCargo(uint256 amount) public {

        // (which is 255), then only the least significant 8 bits are stored in balance.

        uint8 goodsOnHand = uint8(amount);

        // store the balance
        balances[msg.sender] = goodsOnHand;
    }

    function getStocklevel() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract SimpleCargobankV2 {
    using SafeCast for uint256; // Use SafeCast for uint256

    mapping(address => uint) private balances;

    function checkInCargo(uint256 _amount) public {
        // Use the `toUint8()` function from `SafeCast` to safely downcast `amount`.
        // If `amount` is greater than `type(uint8).max`, it will revert.
        // or keep the same uint256 with amount.
        uint8 amount = _amount.toUint8(); // or keep uint256

        // Store the balance
        balances[msg.sender] = amount;
    }

    function getStocklevel() public view returns (uint) {
        return balances[msg.sender];
    }
}
