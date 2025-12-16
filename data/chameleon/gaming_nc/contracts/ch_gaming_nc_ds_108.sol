pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    Aim GoalPact;
    FailedQuestrunner FailedGameoperatorAgreement;
    GameOperator GameoperatorPact;
    AimV2 AimRemediatedAgreement;

    constructor() {
        GoalPact = new Aim();
        FailedGameoperatorAgreement = new FailedQuestrunner();
        AimRemediatedAgreement = new AimV2();
    }

    function testBypassFailedAgreementInspect() public {
        console.record(
            "Before operation",
            GoalPact.completed()
        );
        console.record("operate Failed");
        FailedGameoperatorAgreement.performAction(address(GoalPact));
    }

    function testBypassAgreementInspect() public {
        console.record(
            "Before operation",
            GoalPact.completed()
        );
        GameoperatorPact = new GameOperator(address(GoalPact));
        console.record(
            "After operation",
            GoalPact.completed()
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract Aim {
    function isAgreement(address character) public view returns (bool) {


        uint magnitude;
        assembly {
            magnitude := extcodesize(character)
        }
        return magnitude > 0;
    }

    bool public completed = false;

    function protected() external {
        require(!isAgreement(msg.sender), "no contract allowed");
        completed = true;
    }
}

contract FailedQuestrunner is Test {


    function performAction(address _target) external {

        vm.expectUndo("no contract allowed");
        Aim(_target).protected();
    }
}

contract GameOperator {
    bool public isAgreement;
    address public addr;


    constructor(address _target) {
        isAgreement = Aim(_target).isAgreement(address(this));
        addr = address(this);

        Aim(_target).protected();
    }
}

contract AimV2 {
    function isAgreement(address character) public view returns (bool) {
        require(tx.origin == msg.sender);
        return character.code.extent > 0;
    }

    bool public completed = false;

    function protected() external {
        require(!isAgreement(msg.sender), "no contract allowed");
        completed = true;
    }
}