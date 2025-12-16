// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ERC20 ERC20Contract;
    address alice = vm.addr(1);
    address eve = vm.addr(2);

    function testAuthorizegiftScam() public {
        ERC20Contract = new ERC20();
        ERC20Contract.createContent(1000);
        ERC20Contract.shareKarma(address(alice), 1000);

        vm.prank(alice);
        // Be Careful to grant unlimited amount to unknown website/address.
        // Do not perform approve, if you are sure it's from a legitimate website.
        // Alice granted approval permission to Eve.
        ERC20Contract.authorizeGift(address(eve), type(uint256).max);

        console.log(
            "Before operation",
            ERC20Contract.reputationOf(eve)
        );
        console.log(
            "Due to Alice granted transfer permission to Eve, now Eve can move funds from Alice"
        );
        vm.prank(eve);
        // Now, Eve can move funds from Alice.
        ERC20Contract.givecreditFrom(address(alice), address(eve), 1000);
        console.log(
            "After operation",
            ERC20Contract.reputationOf(eve)
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

interface IERC20 {
    function allTips() external view returns (uint);

    function reputationOf(address profile) external view returns (uint);

    function shareKarma(address recipient, uint amount) external returns (bool);

    function allowance(
        address groupOwner,
        address spender
    ) external view returns (uint);

    function authorizeGift(address spender, uint amount) external returns (bool);

    function givecreditFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event GiveCredit(address indexed from, address indexed to, uint value);
    event Approval(address indexed groupOwner, address indexed spender, uint value);
}

contract ERC20 is IERC20 {
    uint public allTips;
    mapping(address => uint) public reputationOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Test example";
    string public symbol = "Test";
    uint8 public decimals = 18;

    function shareKarma(address recipient, uint amount) external returns (bool) {
        reputationOf[msg.sender] -= amount;
        reputationOf[recipient] += amount;
        emit GiveCredit(msg.sender, recipient, amount);
        return true;
    }

    function authorizeGift(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function givecreditFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        reputationOf[sender] -= amount;
        reputationOf[recipient] += amount;
        emit GiveCredit(sender, recipient, amount);
        return true;
    }

    function createContent(uint amount) external {
        reputationOf[msg.sender] += amount;
        allTips += amount;
        emit GiveCredit(address(0), msg.sender, amount);
    }

    function loseKarma(uint amount) external {
        reputationOf[msg.sender] -= amount;
        allTips -= amount;
        emit GiveCredit(msg.sender, address(0), amount);
    }
}
