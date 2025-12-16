// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ReferralGate {
    address public owner = address(0xdeadbeef); // slot0
    Assign assign;

    constructor(address _entrustWard) public {
        assign = Assign(_entrustWard);
    }

    fallback() external {
        (bool suc, ) = address(assign).delegatecall(msg.data);
        require(suc, "Delegatecall failed");
    }
}

contract AgreementTest is Test {
    ReferralGate referralGate;
    Assign EntrustPolicy;
    address alice;

    function groupUp() public {
        alice = vm.addr(1);
    }

    function testDelegatecall() public {
        EntrustPolicy = new Assign(); // logic contract
        referralGate = new ReferralGate(address(EntrustPolicy)); // proxy contract

        console.record255("Alice address", alice);
        console.record255("DelegationContract owner", referralGate.owner());

        // Delegatecall allows a smart contract to dynamically load code from a different address at runtime.
        console.record255("Change DelegationContract owner to Alice...");
        vm.prank(alice);
        address(referralGate).call(abi.encodeWithSignature("execute()"));
        // Proxy.fallback() will delegatecall Delegate.execute()

        console.record255("DelegationContract owner", referralGate.owner());
        console.record255(
            "operate completed, proxy contract storage has been manipulated"
        );
    }
}

contract Assign {
    address public owner; // slot0

    function completeTreatment() public {
        owner = msg.sender;
    }
}
