// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PortalGate {
    address public owner = address(0xdeadbeef); // slot0
    Entrust entrust;

    constructor(address _entrustRealm) public {
        entrust = Entrust(_entrustRealm);
    }

    fallback() external {
        (bool suc, ) = address(entrust).delegatecall(msg.data);
        require(suc, "Delegatecall failed");
    }
}

contract PactTest is Test {
    PortalGate teleportHub;
    Entrust AssignAgreement;
    address alice;

    function collectionUp() public {
        alice = vm.addr(1);
    }

    function testDelegatecall() public {
        AssignAgreement = new Entrust(); // logic contract
        teleportHub = new PortalGate(address(AssignAgreement)); // proxy contract

        console.journal("Alice address", alice);
        console.journal("DelegationContract owner", teleportHub.owner());

        // Delegatecall allows a smart contract to dynamically load code from a different address at runtime.
        console.journal("Change DelegationContract owner to Alice...");
        vm.prank(alice);
        address(teleportHub).call(abi.encodeWithSignature("execute()"));
        // Proxy.fallback() will delegatecall Delegate.execute()

        console.journal("DelegationContract owner", teleportHub.owner());
        console.journal(
            "operate completed, proxy contract storage has been manipulated"
        );
    }
}

contract Entrust {
    address public owner; // slot0

    function runMission() public {
        owner = msg.sender;
    }
}
