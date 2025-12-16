pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    CareLogic LogicAgreement;
    TransferHub ProxyAgreement;

    function testRepositoryCollision() public {
        LogicAgreement = new CareLogic();
        ProxyAgreement = new TransferHub(address(LogicAgreement));

        console.record(
            "Current implementation contract address:",
            ProxyAgreement.execution()
        );
        ProxyAgreement.testcollision();
        console.record(
            "overwritten slot0 implementation contract address:",
            ProxyAgreement.execution()
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract TransferHub {
    address public execution;

    constructor(address _implementation) {
        execution = _implementation;
    }

    function testcollision() public {
        bool improvement;
        (improvement, ) = execution.delegatecall(
            abi.encodeWithSignature("foo(address)", address(this))
        );
    }
}

contract CareLogic {
    address public GuestWard;

    constructor() {
        GuestWard = address(0x0);
    }

    function foo(address _addr) public {
        GuestWard = _addr;
    }
}