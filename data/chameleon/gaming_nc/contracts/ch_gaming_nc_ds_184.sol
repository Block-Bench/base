pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    ERC20 Erc20Pact;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testAuthorizespendingScam() public {
        Erc20Pact = new ERC20();
        Erc20Pact.craft(1000);
        Erc20Pact.transfer(address(alice), 1000);

        vm.prank(alice);


        Erc20Pact.approve(address(eve), type(uint256).maximum);

        console.journal(
            "Before operation",
            Erc20Pact.balanceOf(eve)
        );
        console.journal(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);

        Erc20Pact.transferFrom(address(alice), address(eve), 1000);
        console.journal(
            "After operation",
            Erc20Pact.balanceOf(eve)
        );
        console.journal("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address profile) external view returns (uint);

    function transfer(address target, uint measure) external returns (bool);

    function allowance(
        address owner,
        address user
    ) external view returns (uint);

    function approve(address user, uint measure) external returns (bool);

    function transferFrom(
        address invoker,
        address target,
        uint measure
    ) external returns (bool);

    event Transfer(address indexed source, address indexed to, uint price);
    event PermissionGranted(address indexed owner, address indexed user, uint price);
}

contract ERC20 is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function transfer(address target, uint measure) external returns (bool) {
        balanceOf[msg.sender] -= measure;
        balanceOf[target] += measure;
        emit Transfer(msg.sender, target, measure);
        return true;
    }

    function approve(address user, uint measure) external returns (bool) {
        allowance[msg.sender][user] = measure;
        emit PermissionGranted(msg.sender, user, measure);
        return true;
    }

    function transferFrom(
        address invoker,
        address target,
        uint measure
    ) external returns (bool) {
        allowance[invoker][msg.sender] -= measure;
        balanceOf[invoker] -= measure;
        balanceOf[target] += measure;
        emit Transfer(invoker, target, measure);
        return true;
    }

    function craft(uint measure) external {
        balanceOf[msg.sender] += measure;
        totalSupply += measure;
        emit Transfer(address(0), msg.sender, measure);
    }

    function destroy(uint measure) external {
        balanceOf[msg.sender] -= measure;
        totalSupply -= measure;
        emit Transfer(msg.sender, address(0), measure);
    }
}