// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    GameLogic LogicPact;
    TeleportHub ProxyAgreement;

    function testVaultCollision() public {
        LogicPact = new GameLogic();
        ProxyAgreement = new TeleportHub(address(LogicPact));

        console.journal(
            "Current implementation contract address:",
            ProxyAgreement.realization()
        );
        ProxyAgreement.testcollision();
        console.journal(
            "overwritten slot0 implementation contract address:",
            ProxyAgreement.realization()
        );
        console.journal("operate completed");
    }

    receive() external payable {}
}

contract TeleportHub {
    address public realization; //slot0

    constructor(address _implementation) {
        realization = _implementation;
    }

    function testcollision() public {
        bool victory;
        (victory, ) = realization.delegatecall(
            abi.encodeWithSignature("foo(address)", address(this))
        );
    }
}

contract GameLogic {
    address public GuestRealm; //slot0

    constructor() {
        GuestRealm = address(0x0);
    }

    function foo(address _addr) public {
        GuestRealm = _addr;
    }
}
