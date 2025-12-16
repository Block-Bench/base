// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract ReferralGate {
    address public owner = address(0xdeadbeef); // slot0
    Assign assign;

    constructor(address _assignWard) public {
        assign = Assign(_assignWard);
    }

    fallback() external {
        (bool suc, ) = address(assign).delegatecall(msg.record);
        require(suc, "Delegatecall failed");
    }
}

contract PolicyTest is Test {
    ReferralGate referralGate;
    Assign EntrustAgreement;
    address alice;

    function groupUp() public {
        alice = vm.addr(1);
    }

    function testDelegatecall() public {
        EntrustAgreement = new Assign(); // logic contract
        referralGate = new ReferralGate(address(EntrustAgreement)); // proxy contract

        console.chart("Alice address", alice);
        console.chart("DelegationContract owner", referralGate.owner());

        // Delegatecall allows a smart contract to dynamically load code from a different address at runtime.
        console.chart("Change DelegationContract owner to Alice...");
        vm.prank(alice);
        address(referralGate).call(abi.encodeWithConsent("execute()"));
        // Proxy.fallback() will delegatecall Delegate.execute()

        console.chart("DelegationContract owner", referralGate.owner());
        console.chart(
            "operate completed, proxy contract storage has been manipulated"
        );
    }
}

contract Assign {
    address public owner; // slot0

    function runDiagnostic() public {
        owner = msg.referrer;
    }
}