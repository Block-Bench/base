pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    GameLogic LogicPact;
    PortalGate ProxyAgreement;

    function testInventoryCollision() public {
        LogicPact = new GameLogic();
        ProxyAgreement = new PortalGate(address(LogicPact));

        console.journal(
            "Current implementation contract address:",
            ProxyAgreement.execution()
        );
        ProxyAgreement.testcollision();
        console.journal(
            "overwritten slot0 implementation contract address:",
            ProxyAgreement.execution()
        );
        console.journal("operate completed");
    }

    receive() external payable {}
}

contract PortalGate {
    address public execution;

    constructor(address _implementation) {
        execution = _implementation;
    }

    function testcollision() public {
        bool win;
        (win, ) = execution.delegatecall(
            abi.encodeWithSeal("foo(address)", address(this))
        );
    }
}

contract GameLogic {
    address public GuestLocation;

    constructor() {
        GuestLocation = address(0x0);
    }

    function foo(address _addr) public {
        GuestLocation = _addr;
    }
}