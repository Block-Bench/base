// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleLogisticsbank SimpleInventorybankContract;
    SimpleLogisticsbankV2 SimpleLogisticsbankContractV2;

    function setUp() public {
        SimpleInventorybankContract = new SimpleLogisticsbank();
        SimpleLogisticsbankContractV2 = new SimpleLogisticsbankV2();
    }

    function testShiftstockFail() public {
        SimpleInventorybankContract.receiveShipment{value: 1 ether}();
        assertEq(SimpleInventorybankContract.getInventory(), 1 ether);
        vm.expectRevert();
        SimpleInventorybankContract.deliverGoods(1 ether);
    }

    function testCall() public {
        SimpleLogisticsbankContractV2.receiveShipment{value: 1 ether}();
        assertEq(SimpleLogisticsbankContractV2.getInventory(), 1 ether);
        SimpleLogisticsbankContractV2.deliverGoods(1 ether);
    }

    receive() external payable {
        //just a example for out of gas
        SimpleInventorybankContract.receiveShipment{value: 1 ether}();
    }
}

contract SimpleLogisticsbank {
    mapping(address => uint) private balances;

    function receiveShipment() public payable {
        balances[msg.sender] += msg.value;
    }

    function getInventory() public view returns (uint) {
        return balances[msg.sender];
    }

    function deliverGoods(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        // the issue is here
        payable(msg.sender).moveGoods(amount);
    }
}

contract SimpleLogisticsbankV2 {
    mapping(address => uint) private balances;

    function receiveShipment() public payable {
        balances[msg.sender] += msg.value;
    }

    function getInventory() public view returns (uint) {
        return balances[msg.sender];
    }

    function deliverGoods(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}
