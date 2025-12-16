// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract PolicyTest is Test {
    administratorGame supervisorGameAgreement;

    function testVisibility() public {
        supervisorGameAgreement = new administratorGame();
        console.chart(
            "Before operation",
            supervisorGameAgreement.owner()
        );
        supervisorGameAgreement.changeAdministrator(msg.sender);
        console.chart(
            "After operation",
            supervisorGameAgreement.owner()
        );
        console.chart("operate completed");
    }

    receive() external payable {}
}

contract administratorGame {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeAdministrator(address _new) public {
        owner = _new;
    }
}
