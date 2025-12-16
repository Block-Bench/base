// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    ownerGame ownerGameContract;

    function testVisibility() public {
        _doTestVisibilityCore(msg.sender);
    }

    function _doTestVisibilityCore(address _sender) internal {
        ownerGameContract = new ownerGame();
        console.log(
        "Before operation",
        ownerGameContract.owner()
        );
        ownerGameContract.changeOwner(_sender);
        console.log(
        "After operation",
        ownerGameContract.owner()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract ownerGame {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeOwner(address _new) public {
        owner = _new;
    }
}
