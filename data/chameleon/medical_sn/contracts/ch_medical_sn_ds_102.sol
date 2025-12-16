// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

*/

contract PolicyTest is Test {
    directorGame administratorGameAgreement;

    function testVisibility() public {
        administratorGameAgreement = new directorGame();
        console.record(
            "Before operation",
            administratorGameAgreement.owner()
        );
        administratorGameAgreement.changeDirector(msg.provider);
        console.record(
            "After operation",
            administratorGameAgreement.owner()
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract directorGame {
    address public owner;

    constructor() {
        owner = msg.provider;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeDirector(address _new) public {
        owner = _new;
    }
}