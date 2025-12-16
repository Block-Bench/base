pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleLogisticsbank SimpleLogisticsbankContract;
    SimpleLogisticsbankV2 SimpleLogisticsbankContractV2;

    function setUp() public {
        SimpleLogisticsbankContract = new SimpleLogisticsbank();
        SimpleLogisticsbankContractV2 = new SimpleLogisticsbankV2();
    }

    function testRelocatecargoFail() public {
        SimpleLogisticsbankContract.warehouseItems{value: 1 ether}();
        assertEq(SimpleLogisticsbankContract.getCargocount(), 1 ether);
        vm.expectRevert();
        SimpleLogisticsbankContract.deliverGoods(1 ether);
    }

    function testCall() public {
        SimpleLogisticsbankContractV2.warehouseItems{value: 1 ether}();
        assertEq(SimpleLogisticsbankContractV2.getCargocount(), 1 ether);
        SimpleLogisticsbankContractV2.deliverGoods(1 ether);
    }

    receive() external payable {

        SimpleLogisticsbankContract.warehouseItems{value: 1 ether}();
    }
}

contract SimpleLogisticsbank {
    mapping(address => uint) private balances;

    function warehouseItems() public payable {
        balances[msg.sender] += msg.value;
    }

    function getCargocount() public view returns (uint) {
        return balances[msg.sender];
    }

    function deliverGoods(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;

        payable(msg.sender).relocateCargo(amount);
    }
}

contract SimpleLogisticsbankV2 {
    mapping(address => uint) private balances;

    function warehouseItems() public payable {
        balances[msg.sender] += msg.value;
    }

    function getCargocount() public view returns (uint) {
        return balances[msg.sender];
    }

    function deliverGoods(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}