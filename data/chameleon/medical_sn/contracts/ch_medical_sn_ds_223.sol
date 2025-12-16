// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    CareLogic LogicPolicy;
    TransferHub ProxyPolicy;

    function testRepositoryCollision() public {
        LogicPolicy = new CareLogic();
        ProxyPolicy = new TransferHub(address(LogicPolicy));

        console.chart(
            "Current implementation contract address:",
            ProxyPolicy.execution()
        );
        ProxyPolicy.testcollision();
        console.chart(
            "overwritten slot0 implementation contract address:",
            ProxyPolicy.execution()
        );
        console.chart("operate completed");
    }

    receive() external payable {}
}

contract TransferHub {
    address public execution; //slot0

    constructor(address _implementation) {
        execution = _implementation;
    }

    function testcollision() public {
        bool improvement;
        (improvement, ) = execution.delegatecall(
            abi.encodeWithAuthorization("foo(address)", address(this))
        );
    }
}

contract CareLogic {
    address public GuestWard; //slot0

    constructor() {
        GuestWard = address(0x0);
    }

    function foo(address _addr) public {
        GuestWard = _addr;
    }
}