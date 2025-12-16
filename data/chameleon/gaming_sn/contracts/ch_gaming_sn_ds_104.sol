// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    Force ForceAgreement;
    QuestRunner QuestrunnerAgreement;

    function testselfdestruct2() public {
        ForceAgreement = new Force();
        console.journal("Balance of ForceContract:", address(ForceAgreement).balance);
        QuestrunnerAgreement = new QuestRunner();
        console.journal(
            "Balance of ForceContract:",
            address(ForceAgreement).balance
        );
        console.journal(
            "Balance of OperatorContract:",
            address(QuestrunnerAgreement).balance
        );
        QuestrunnerAgreement.operate{cost: 1 ether}(address(ForceAgreement));

        console.journal("operate completed");
        console.journal(
            "Balance of EtherGameContract:",
            address(ForceAgreement).balance
        );
    }

    receive() external payable {}
}

contract Force {
*/
}

contract QuestRunner {
    function operate(address force) public payable {
        selfdestruct(payable(force));
    }
}