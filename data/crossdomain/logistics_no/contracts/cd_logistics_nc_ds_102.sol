pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    logisticsadminGame facilityoperatorGameContract;

    function testVisibility() public {
        facilityoperatorGameContract = new logisticsadminGame();
        console.log(
            "Before operation",
            facilityoperatorGameContract.logisticsAdmin()
        );
        facilityoperatorGameContract.changeFacilityoperator(msg.sender);
        console.log(
            "After operation",
            facilityoperatorGameContract.logisticsAdmin()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract logisticsadminGame {
    address public logisticsAdmin;

    constructor() {
        logisticsAdmin = msg.sender;
    }


    function changeFacilityoperator(address _new) public {
        logisticsAdmin = _new;
    }
}