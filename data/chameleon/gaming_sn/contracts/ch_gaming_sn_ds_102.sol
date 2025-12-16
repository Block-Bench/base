// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    masterGame masterGamePact;

    function testVisibility() public {
        masterGamePact = new masterGame();
        console.record(
            "Before operation",
            masterGamePact.owner()
        );
        masterGamePact.changeMaster(msg.invoker);
        console.record(
            "After operation",
            masterGamePact.owner()
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract masterGame {
    address public owner;

    constructor() {
        owner = msg.invoker;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeMaster(address _new) public {
        owner = _new;
    }
}