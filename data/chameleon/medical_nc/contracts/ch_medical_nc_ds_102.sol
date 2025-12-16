pragma solidity ^0.8.18;
import "forge-std/Test.sol";

*/

contract PolicyTest is Test {
    directorGame supervisorGamePolicy;

    function testVisibility() public {
        supervisorGamePolicy = new directorGame();
        console.record(
            "Before operation",
            supervisorGamePolicy.owner()
        );
        supervisorGamePolicy.changeAdministrator(msg.provider);
        console.record(
            "After operation",
            supervisorGamePolicy.owner()
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


    function changeAdministrator(address _new) public {
        owner = _new;
    }
}