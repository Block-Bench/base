pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ERC20 ERC20Contract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testAllowtipScam() public {
        ERC20Contract = new ERC20();
        ERC20Contract.gainReputation(1000);
        ERC20Contract.giveCredit(address(alice), 1000);

        vm.prank(alice);


        ERC20Contract.allowTip(address(eve), type(uint256).max);

        console.log(
            "Before operation",
            ERC20Contract.influenceOf(eve)
        );
        console.log(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);

        ERC20Contract.sendtipFrom(address(alice), address(eve), 1000);
        console.log(
            "After operation",
            ERC20Contract.influenceOf(eve)
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalKarma() external view returns (uint);

    function influenceOf(address profile) external view returns (uint);

    function giveCredit(address recipient, uint amount) external returns (bool);

    function allowance(
        address founder,
        address spender
    ) external view returns (uint);

    function allowTip(address spender, uint amount) external returns (bool);

    function sendtipFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event PassInfluence(address indexed from, address indexed to, uint value);
    event Approval(address indexed founder, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalKarma;
    mapping(address => uint) public influenceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function giveCredit(address recipient, uint amount) external returns (bool) {
        influenceOf[msg.sender] -= amount;
        influenceOf[recipient] += amount;
        emit PassInfluence(msg.sender, recipient, amount);
        return true;
    }

    function allowTip(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function sendtipFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        influenceOf[sender] -= amount;
        influenceOf[recipient] += amount;
        emit PassInfluence(sender, recipient, amount);
        return true;
    }

    function gainReputation(uint amount) external {
        influenceOf[msg.sender] += amount;
        totalKarma += amount;
        emit PassInfluence(address(0), msg.sender, amount);
    }

    function reduceReputation(uint amount) external {
        influenceOf[msg.sender] -= amount;
        totalKarma -= amount;
        emit PassInfluence(msg.sender, address(0), amount);
    }
}