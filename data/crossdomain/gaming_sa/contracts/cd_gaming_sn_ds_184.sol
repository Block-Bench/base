// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ERC20 ERC20Contract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testAuthorizedealScam() public {
        ERC20Contract = new ERC20();
        ERC20Contract.generateLoot(1000);
        ERC20Contract.giveItems(address(alice), 1000);

        vm.prank(alice);
        // Be Careful to grant unlimited amount to unknown website/address.
        // Do not perform approve, if you are sure it's from a legitimate website.
        // Alice granted approval permission to Eve.
        ERC20Contract.authorizeDeal(address(eve), type(uint256).max);

        console.log(
            "Before operation",
            ERC20Contract.lootbalanceOf(eve)
        );
        console.log(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);
        // Now, Eve can move funds from Alice.
        ERC20Contract.tradelootFrom(address(alice), address(eve), 1000);
        console.log(
            "After operation",
            ERC20Contract.lootbalanceOf(eve)
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function worldSupply() external view returns (uint);

    function lootbalanceOf(address playerAccount) external view returns (uint);

    function giveItems(address recipient, uint amount) external returns (bool);

    function allowance(
        address guildLeader,
        address spender
    ) external view returns (uint);

    function authorizeDeal(address spender, uint amount) external returns (bool);

    function tradelootFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event GiveItems(address indexed from, address indexed to, uint value);
    event Approval(address indexed guildLeader, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public worldSupply;
    mapping(address => uint) public lootbalanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function giveItems(address recipient, uint amount) external returns (bool) {
        lootbalanceOf[msg.sender] -= amount;
        lootbalanceOf[recipient] += amount;
        emit GiveItems(msg.sender, recipient, amount);
        return true;
    }

    function authorizeDeal(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function tradelootFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        lootbalanceOf[sender] -= amount;
        lootbalanceOf[recipient] += amount;
        emit GiveItems(sender, recipient, amount);
        return true;
    }

    function generateLoot(uint amount) external {
        lootbalanceOf[msg.sender] += amount;
        worldSupply += amount;
        emit GiveItems(address(0), msg.sender, amount);
    }

    function consumePotion(uint amount) external {
        lootbalanceOf[msg.sender] -= amount;
        worldSupply -= amount;
        emit GiveItems(msg.sender, address(0), amount);
    }
}
