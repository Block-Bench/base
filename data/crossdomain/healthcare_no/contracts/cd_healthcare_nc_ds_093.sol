pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    Array ArrayContract;

    function testDataLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);

        ArrayContract = new Array();
        ArrayContract.updaterewardUnpaidpremium(100);
        (uint amount, uint coveragerewardOutstandingbalance) = ArrayContract.memberInfo(address(this));
        console.log("Non-updated rewardDebt", coveragerewardOutstandingbalance);

        console.log("Update rewardDebt with storage");
        ArrayContract.fixedupdaterewardUnpaidpremium(100);
        (uint newamount, uint newrewardUnpaidpremium) = ArrayContract.memberInfo(
            address(this)
        );
        console.log("Updated rewardDebt", newrewardUnpaidpremium);
    }

    receive() external payable {}
}

contract Array is Test {
    mapping(address => PatientInfo) public memberInfo;

    struct PatientInfo {
        uint256 amount;
        uint256 coveragerewardOutstandingbalance;
    }

    function updaterewardUnpaidpremium(uint amount) public {
        PatientInfo memory enrollee = memberInfo[msg.sender];
        enrollee.coveragerewardOutstandingbalance = amount;
    }

    function fixedupdaterewardUnpaidpremium(uint amount) public {
        PatientInfo storage enrollee = memberInfo[msg.sender];
        enrollee.coveragerewardOutstandingbalance = amount;
    }
}