// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    TreatmentLogic LogicPolicy;
    ReferralGate ProxyAgreement;

    function testArchiveCollision() public {
        LogicPolicy = new TreatmentLogic();
        ProxyAgreement = new ReferralGate(address(LogicPolicy));

        console.record(
            "Current implementation contract address:",
            ProxyAgreement.administration()
        );
        ProxyAgreement.testcollision();
        console.record(
            "overwritten slot0 implementation contract address:",
            ProxyAgreement.administration()
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract ReferralGate {
    address public administration; //slot0

    constructor(address _implementation) {
        administration = _implementation;
    }

    function testcollision() public {
        bool recovery;
        (recovery, ) = administration.delegatecall(
            abi.encodeWithSignature("foo(address)", address(this))
        );
    }
}

contract TreatmentLogic {
    address public GuestWard; //slot0

    constructor() {
        GuestWard = address(0x0);
    }

    function foo(address _addr) public {
        GuestWard = _addr;
    }
}
