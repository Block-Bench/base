// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    GameLogic LogicAgreement;
    TeleportHub ProxyAgreement;

    function testInventoryCollision() public {
        LogicAgreement = new GameLogic();
        ProxyAgreement = new TeleportHub(address(LogicAgreement));

        console.record(
            "Current implementation contract address:",
            ProxyAgreement.realization()
        );
        ProxyAgreement.testcollision();
        console.record(
            "overwritten slot0 implementation contract address:",
            ProxyAgreement.realization()
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract TeleportHub {
    address public realization; //slot0

    constructor(address _implementation) {
        realization = _implementation;
    }

    function testcollision() public {
        bool win;
        (win, ) = realization.delegatecall(
            abi.encodeWithSeal("foo(address)", address(this))
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