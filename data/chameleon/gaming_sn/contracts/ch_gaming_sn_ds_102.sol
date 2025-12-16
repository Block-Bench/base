// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract PactTest is Test {
    lordGame lordGameAgreement;

    function testVisibility() public {
        lordGameAgreement = new lordGame();
        console.record(
            "Before operation",
            lordGameAgreement.owner()
        );
        lordGameAgreement.changeLord(msg.sender);
        console.record(
            "After operation",
            lordGameAgreement.owner()
        );
        console.record("operate completed");
    }

    receive() external payable {}
}

contract lordGame {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeLord(address _new) public {
        owner = _new;
    }
}
