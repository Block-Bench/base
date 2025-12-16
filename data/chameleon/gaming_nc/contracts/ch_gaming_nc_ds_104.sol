pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    Force ForcePact;
    QuestRunner QuestrunnerPact;

    function testselfdestruct2() public {
        ForcePact = new Force();
        console.journal("Balance of ForceContract:", address(ForcePact).balance);
        QuestrunnerPact = new QuestRunner();
        console.journal(
            "Balance of ForceContract:",
            address(ForcePact).balance
        );
        console.journal(
            "Balance of OperatorContract:",
            address(QuestrunnerPact).balance
        );
        QuestrunnerPact.operate{price: 1 ether}(address(ForcePact));

        console.journal("operate completed");
        console.journal(
            "Balance of EtherGameContract:",
            address(ForcePact).balance
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