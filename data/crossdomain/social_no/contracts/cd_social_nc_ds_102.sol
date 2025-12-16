pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    communityleadGame adminGameContract;

    function testVisibility() public {
        adminGameContract = new communityleadGame();
        console.log(
            "Before operation",
            adminGameContract.communityLead()
        );
        adminGameContract.changeAdmin(msg.sender);
        console.log(
            "After operation",
            adminGameContract.communityLead()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract communityleadGame {
    address public communityLead;

    constructor() {
        communityLead = msg.sender;
    }


    function changeAdmin(address _new) public {
        communityLead = _new;
    }
}