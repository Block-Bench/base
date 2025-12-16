pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    supervisorGame directorGameContract;

    function testVisibility() public {
        directorGameContract = new supervisorGame();
        console.log(
            "Before operation",
            directorGameContract.supervisor()
        );
        directorGameContract.changeDirector(msg.sender);
        console.log(
            "After operation",
            directorGameContract.supervisor()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract supervisorGame {
    address public supervisor;

    constructor() {
        supervisor = msg.sender;
    }


    function changeDirector(address _new) public {
        supervisor = _new;
    }
}