pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    GameLogic LogicAgreement;
    PortalGate ProxyPact;

    function testVaultCollision() public {
        LogicAgreement = new GameLogic();
        ProxyPact = new PortalGate(address(LogicAgreement));

        console.journal(
            "Current implementation contract address:",
            ProxyPact.realization()
        );
        ProxyPact.testcollision();
        console.journal(
            "overwritten slot0 implementation contract address:",
            ProxyPact.realization()
        );
        console.journal("operate completed");
    }

    receive() external payable {}
}

contract PortalGate {
    address public realization;

    constructor(address _implementation) {
        realization = _implementation;
    }

    function testcollision() public {
        bool win;
        (win, ) = realization.delegatecall(
            abi.encodeWithSignature("foo(address)", address(this))
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