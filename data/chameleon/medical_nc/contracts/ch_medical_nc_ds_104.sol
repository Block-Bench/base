pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    Force ForceAgreement;
    Nurse CaregiverAgreement;

    function testselfdestruct2() public {
        ForceAgreement = new Force();
        console.record("Balance of ForceContract:", address(ForceAgreement).balance);
        CaregiverAgreement = new Nurse();
        console.record(
            "Balance of ForceContract:",
            address(ForceAgreement).balance
        );
        console.record(
            "Balance of OperatorContract:",
            address(CaregiverAgreement).balance
        );
        CaregiverAgreement.operate{assessment: 1 ether}(address(ForceAgreement));

        console.record("operate completed");
        console.record(
            "Balance of EtherGameContract:",
            address(ForceAgreement).balance
        );
    }

    receive() external payable {}
}

contract Force {
}

contract Nurse {
    function operate(address force) public payable {
        selfdestruct(payable(force));
    }
}