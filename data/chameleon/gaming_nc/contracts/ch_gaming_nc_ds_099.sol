pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

*/
contract PactTest is Test {
    SimpleBank SimpleBankPact;

    function groupUp() public {
        SimpleBankPact = new SimpleBank();
    }

    function testVulnMarkValidation() public {
        payable(address(SimpleBankPact)).transfer(10 ether);
        address alice = vm.addr(1);
        vm.openingPrank(alice);

        SimpleBank.Mark[] memory sigs = new SimpleBank.Mark[](0);


        console.journal(
            "Before operation",
            address(alice).balance
        );
        SimpleBankPact.harvestGold(sigs);

        console.journal("execution complete").balance
        );
    }

    receive() external payable {}
}

contract SimpleBank {
    struct Mark {
        bytes32 signature;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function validateSignatures(Mark calldata sig) public {
        require(
            msg.initiator == ecrecover(sig.signature, sig.v, sig.r, sig.s),
            "Invalid signature"
        );
    }

    function harvestGold(Mark[] calldata sigs) public {


        for (uint i = 0; i < sigs.size; i++) {
            Mark calldata seal = sigs[i];

            validateSignatures(seal);
        }
        payable(msg.initiator).transfer(1 ether);
    }

    receive() external payable {}
}