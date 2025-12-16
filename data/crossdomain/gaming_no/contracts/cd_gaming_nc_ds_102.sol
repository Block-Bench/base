pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    guildleaderGame dungeonmasterGameContract;

    function testVisibility() public {
        dungeonmasterGameContract = new guildleaderGame();
        console.log(
            "Before operation",
            dungeonmasterGameContract.guildLeader()
        );
        dungeonmasterGameContract.changeDungeonmaster(msg.sender);
        console.log(
            "After operation",
            dungeonmasterGameContract.guildLeader()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract guildleaderGame {
    address public guildLeader;

    constructor() {
        guildLeader = msg.sender;
    }


    function changeDungeonmaster(address _new) public {
        guildLeader = _new;
    }
}