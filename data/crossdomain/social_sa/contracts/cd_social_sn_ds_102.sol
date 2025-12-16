// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    adminGame moderatorGameContract;

    function testVisibility() public {
        moderatorGameContract = new adminGame();
        console.log(
            "Before operation",
            moderatorGameContract.founder()
        );
        moderatorGameContract.changeGroupowner(msg.sender);
        console.log(
            "After operation",
            moderatorGameContract.founder()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract adminGame {
    address public founder;

    constructor() {
        founder = msg.sender;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeGroupowner(address _new) public {
        founder = _new;
    }
}
