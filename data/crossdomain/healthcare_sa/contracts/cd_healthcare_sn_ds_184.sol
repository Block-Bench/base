// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ERC20 ERC20Contract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testValidateclaimScam() public {
        ERC20Contract = new ERC20();
        ERC20Contract.createBenefit(1000);
        ERC20Contract.transferBenefit(address(alice), 1000);

        vm.prank(alice);
        // Be Careful to grant unlimited amount to unknown website/address.
        // Do not perform approve, if you are sure it's from a legitimate website.
        // Alice granted approval permission to Eve.
        ERC20Contract.permitPayout(address(eve), type(uint256).max);

        console.log(
            "Before operation",
            ERC20Contract.remainingbenefitOf(eve)
        );
        console.log(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);
        // Now, Eve can move funds from Alice.
        ERC20Contract.assigncreditFrom(address(alice), address(eve), 1000);
        console.log(
            "After operation",
            ERC20Contract.remainingbenefitOf(eve)
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalCoverage() external view returns (uint);

    function remainingbenefitOf(address coverageProfile) external view returns (uint);

    function transferBenefit(address recipient, uint amount) external returns (bool);

    function allowance(
        address supervisor,
        address spender
    ) external view returns (uint);

    function permitPayout(address spender, uint amount) external returns (bool);

    function assigncreditFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event MoveCoverage(address indexed from, address indexed to, uint value);
    event Approval(address indexed supervisor, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalCoverage;
    mapping(address => uint) public remainingbenefitOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function transferBenefit(address recipient, uint amount) external returns (bool) {
        remainingbenefitOf[msg.sender] -= amount;
        remainingbenefitOf[recipient] += amount;
        emit MoveCoverage(msg.sender, recipient, amount);
        return true;
    }

    function permitPayout(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function assigncreditFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        remainingbenefitOf[sender] -= amount;
        remainingbenefitOf[recipient] += amount;
        emit MoveCoverage(sender, recipient, amount);
        return true;
    }

    function createBenefit(uint amount) external {
        remainingbenefitOf[msg.sender] += amount;
        totalCoverage += amount;
        emit MoveCoverage(address(0), msg.sender, amount);
    }

    function cancelBenefit(uint amount) external {
        remainingbenefitOf[msg.sender] -= amount;
        totalCoverage -= amount;
        emit MoveCoverage(msg.sender, address(0), amount);
    }
}
