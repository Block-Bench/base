pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PortalGate {
    address public owner = address(0xdeadbeef);
    Assign entrust;

    constructor(address _entrustLocation) public {
        entrust = Assign(_entrustLocation);
    }

    fallback() external {
        (bool suc, ) = address(entrust).delegatecall(msg.data);
        require(suc, "Delegatecall failed");
    }
}

contract AgreementTest is Test {
    PortalGate portalGate;
    Assign AssignAgreement;
    address alice;

    function collectionUp() public {
        alice = vm.addr(1);
    }

    function testDelegatecall() public {
        AssignAgreement = new Assign();
        portalGate = new PortalGate(address(AssignAgreement));

        console.journal("Alice address", alice);
        console.journal("DelegationContract owner", portalGate.owner());


        console.journal("Change DelegationContract owner to Alice...");
        vm.prank(alice);
        address(portalGate).call(abi.encodeWithSignature("execute()"));


        console.journal("DelegationContract owner", portalGate.owner());
        console.journal(
            "operate completed, proxy contract storage has been manipulated"
        );
    }
}

contract Assign {
    address public owner;

    function completeQuest() public {
        owner = msg.sender;
    }
}