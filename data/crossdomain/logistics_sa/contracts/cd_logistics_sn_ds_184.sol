// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ERC20 ERC20Contract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testApprovedispatchScam() public {
        ERC20Contract = new ERC20();
        ERC20Contract.createManifest(1000);
        ERC20Contract.moveGoods(address(alice), 1000);

        vm.prank(alice);
        // Be Careful to grant unlimited amount to unknown website/address.
        // Do not perform approve, if you are sure it's from a legitimate website.
        // Alice granted approval permission to Eve.
        ERC20Contract.clearCargo(address(eve), type(uint256).max);

        console.log(
            "Before operation",
            ERC20Contract.warehouselevelOf(eve)
        );
        console.log(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);
        // Now, Eve can move funds from Alice.
        ERC20Contract.shiftstockFrom(address(alice), address(eve), 1000);
        console.log(
            "After operation",
            ERC20Contract.warehouselevelOf(eve)
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function totalInventory() external view returns (uint);

    function warehouselevelOf(address logisticsAccount) external view returns (uint);

    function moveGoods(address recipient, uint amount) external returns (bool);

    function allowance(
        address logisticsAdmin,
        address spender
    ) external view returns (uint);

    function clearCargo(address spender, uint amount) external returns (bool);

    function shiftstockFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event RelocateCargo(address indexed from, address indexed to, uint value);
    event Approval(address indexed logisticsAdmin, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public totalInventory;
    mapping(address => uint) public warehouselevelOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function moveGoods(address recipient, uint amount) external returns (bool) {
        warehouselevelOf[msg.sender] -= amount;
        warehouselevelOf[recipient] += amount;
        emit RelocateCargo(msg.sender, recipient, amount);
        return true;
    }

    function clearCargo(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function shiftstockFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        warehouselevelOf[sender] -= amount;
        warehouselevelOf[recipient] += amount;
        emit RelocateCargo(sender, recipient, amount);
        return true;
    }

    function createManifest(uint amount) external {
        warehouselevelOf[msg.sender] += amount;
        totalInventory += amount;
        emit RelocateCargo(address(0), msg.sender, amount);
    }

    function delistGoods(uint amount) external {
        warehouselevelOf[msg.sender] -= amount;
        totalInventory -= amount;
        emit RelocateCargo(msg.sender, address(0), amount);
    }
}
