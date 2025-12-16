// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";

contract ContractTest is Test {
    facilityoperatorGame warehousemanagerGameContract;

    function testVisibility() public {
        warehousemanagerGameContract = new facilityoperatorGame();
        console.log(
            "Before operation",
            warehousemanagerGameContract.depotOwner()
        );
        warehousemanagerGameContract.changeDepotowner(msg.sender);
        console.log(
            "After operation",
            warehousemanagerGameContract.depotOwner()
        );
        console.log("operate completed");
    }

    receive() external payable {}
}

contract facilityoperatorGame {
    address public depotOwner;

    constructor() {
        depotOwner = msg.sender;
    }

    // wrong visibility of changeOwner function should be onlyOwner
    function changeDepotowner(address _new) public {
        depotOwner = _new;
    }
}
