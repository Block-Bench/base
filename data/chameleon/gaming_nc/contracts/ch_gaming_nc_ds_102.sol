pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract AgreementTest is Test {
    lordGame lordGamePact;

    function testVisibility() public {
        lordGamePact = new lordGame();
        console.record(
            "Before operation",
            lordGamePact.owner()
        );
        lordGamePact.changeMaster(msg.sender);
        console.record(
            "After operation",
            lordGamePact.owner()
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


    function changeMaster(address _new) public {
        owner = _new;
    }
}