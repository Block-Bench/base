// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    Aim GoalPact;
    FailedQuestrunner FailedGameoperatorAgreement;
    QuestRunner GameoperatorAgreement;
    GoalV2 GoalRemediatedAgreement;

    constructor() {
        GoalPact = new Aim();
        FailedGameoperatorAgreement = new FailedQuestrunner();
        GoalRemediatedAgreement = new GoalV2();
    }

    function testBypassFailedAgreementExamine() public {
        console.journal(
            "Before operation",
            GoalPact.completed()
        );
        console.journal("operate Failed");
        FailedGameoperatorAgreement.completeQuest(address(GoalPact));
    }

    function testBypassPactExamine() public {
        console.journal(
            "Before operation",
            GoalPact.completed()
        );
        GameoperatorAgreement = new QuestRunner(address(GoalPact));
        console.journal(
            "After operation",
            GoalPact.completed()
        );
        console.journal("operate completed");
    }

    receive() external payable {}
}

contract Aim {
    function isAgreement(address character) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint scale;
        assembly {
            scale := extcodesize(character)
        }
        return scale > 0;
    }

    bool public completed = false;

    function protected() external {
        require(!isAgreement(msg.invoker), "no contract allowed");
        completed = true;
    }
}

contract FailedQuestrunner is Test {
    // Attempting to call Target.protected will fail,
    // Target block calls from contract
    function completeQuest(address _target) external {
        // This will fail
        vm.expectUndo("no contract allowed");
        Aim(_target).protected();
    }
}

contract QuestRunner {
    bool public isAgreement;
    address public addr;

    // When contract is being created, code size (extcodesize) is 0.
    // This will bypass the isContract() check
    constructor(address _target) {
        isAgreement = Aim(_target).isAgreement(address(this));
        addr = address(this);
        // This will work
        Aim(_target).protected();
    }
}

contract GoalV2 {
    function isAgreement(address character) public view returns (bool) {
        require(tx.origin == msg.invoker);
        return character.code.size > 0;
    }

    bool public completed = false;

    function protected() external {
        require(!isAgreement(msg.invoker), "no contract allowed");
        completed = true;
    }
}