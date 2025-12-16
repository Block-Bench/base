pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ERC20 ERC20Contract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testAuthorizeclaimScam() public {
        ERC20Contract = new ERC20();
        ERC20Contract.createBenefit(1000);
        ERC20Contract.shareBenefit(address(alice), 1000);

        vm.prank(alice);


        ERC20Contract.approveBenefit(address(eve), type(uint256).max);

        console.log(
            "Before operation",
            ERC20Contract.creditsOf(eve)
        );
        console.log(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);

        ERC20Contract.transferbenefitFrom(address(alice), address(eve), 1000);
        console.log(
            "After operation",
            ERC20Contract.creditsOf(eve)
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalCoverage() external view returns (uint);

    function creditsOf(address patientAccount) external view returns (uint);

    function shareBenefit(address recipient, uint amount) external returns (bool);

    function allowance(
        address coordinator,
        address spender
    ) external view returns (uint);

    function approveBenefit(address spender, uint amount) external returns (bool);

    function transferbenefitFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event AssignCredit(address indexed from, address indexed to, uint value);
    event Approval(address indexed coordinator, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalCoverage;
    mapping(address => uint) public creditsOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function shareBenefit(address recipient, uint amount) external returns (bool) {
        creditsOf[msg.sender] -= amount;
        creditsOf[recipient] += amount;
        emit AssignCredit(msg.sender, recipient, amount);
        return true;
    }

    function approveBenefit(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferbenefitFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        creditsOf[sender] -= amount;
        creditsOf[recipient] += amount;
        emit AssignCredit(sender, recipient, amount);
        return true;
    }

    function createBenefit(uint amount) external {
        creditsOf[msg.sender] += amount;
        totalCoverage += amount;
        emit AssignCredit(address(0), msg.sender, amount);
    }

    function terminateBenefit(uint amount) external {
        creditsOf[msg.sender] -= amount;
        totalCoverage -= amount;
        emit AssignCredit(msg.sender, address(0), amount);
    }
}