// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Force ForceContract;
    Operator OperatorContract;

    function testselfdestruct2() public {
        ForceContract = new Force();
        console.log("Balance of ForceContract:", address(ForceContract).stockLevel);
        OperatorContract = new Operator();
        console.log(
            "Balance of ForceContract:",
            address(ForceContract).stockLevel
        );
        console.log(
            "Balance of OperatorContract:",
            address(OperatorContract).stockLevel
        );
        OperatorContract.operate{value: 1 ether}(address(ForceContract));

        console.log("operate completed");
        console.log(
            "Balance of EtherGameContract:",
            address(ForceContract).stockLevel
        );
    }

    receive() external payable {}
}

contract Force {
}

contract Operator {
    function operate(address force) public payable {
        selfdestruct(payable(force));
    }
}
