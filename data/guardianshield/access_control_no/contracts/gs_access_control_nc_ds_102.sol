pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    constructor() {
        owner = msg.sender;
    }

    ownerGame ownerGameContract;

    function testVisibility() public {
        ownerGameContract = new ownerGame();
        console.log(
            "Before operation",
            ownerGameContract.owner()
        );
        ownerGameContract.changeOwner(msg.sender);
        console.log(
            "After operation",
            ownerGameContract.owner()
        );
        console.log("operate completed");
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

contract ownerGame {
    address public owner;

    constructor() {
        owner = msg.sender;
    }


    function changeOwner(address _new) public onlyOwner {
        owner = _new;
    }
}