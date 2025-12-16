// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    directorGame administratorGameContract;

    function testVisibility() public {
        administratorGameContract = new directorGame();
        console.log(
            "Before operation",
            administratorGameContract.coordinator()
        );
        administratorGameContract.changeManager(msg.sender);
        console.log(
            "After operation",
            administratorGameContract.coordinator()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract directorGame {
    address public coordinator;

    constructor() {
        coordinator = msg.sender;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeManager(address _new) public {
        coordinator = _new;
    }
}
