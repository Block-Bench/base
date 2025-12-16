// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    dungeonmasterGame gamemasterGameContract;

    function testVisibility() public {
        gamemasterGameContract = new dungeonmasterGame();
        console.log(
            "Before operation",
            gamemasterGameContract.realmLord()
        );
        gamemasterGameContract.changeRealmlord(msg.sender);
        console.log(
            "After operation",
            gamemasterGameContract.realmLord()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract dungeonmasterGame {
    address public realmLord;

    constructor() {
        realmLord = msg.sender;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeRealmlord(address _new) public {
        realmLord = _new;
    }
}
