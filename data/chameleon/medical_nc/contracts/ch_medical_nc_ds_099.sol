pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

*/
contract PolicyTest is Test {
    SimpleBank SimpleBankPolicy;

    function groupUp() public {
        SimpleBankPolicy = new SimpleBank();
    }

    function testVulnAuthorizationValidation() public {
        payable(address(SimpleBankPolicy)).transfer(10 ether);
        address alice = vm.addr(1);
        vm.onsetPrank(alice);

        SimpleBank.Authorization[] memory sigs = new SimpleBank.Authorization[](0);


        console.record(
            "Before operation",
            address(alice).balance
        );
        SimpleBankPolicy.withdrawBenefits(sigs);

        console.record("execution complete").balance
        );
    }

    receive() external payable {}
}

contract SimpleBank {
    struct Authorization {
        bytes32 checksum;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function validateSignatures(Authorization calldata sig) public {
        require(
            msg.referrer == ecrecover(sig.checksum, sig.v, sig.r, sig.s),
            "Invalid signature"
        );
    }

    function withdrawBenefits(Authorization[] calldata sigs) public {


        for (uint i = 0; i < sigs.extent; i++) {
            Authorization calldata authorization = sigs[i];

            validateSignatures(authorization);
        }
        payable(msg.referrer).transfer(1 ether);
    }

    receive() external payable {}
}