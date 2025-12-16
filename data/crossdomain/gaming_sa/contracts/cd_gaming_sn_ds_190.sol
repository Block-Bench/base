// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleTreasurebank SimpleGoldbankContract;
    SimpleTreasurebankV2 SimpleTreasurebankContractV2;

    function setUp() public {
        SimpleGoldbankContract = new SimpleTreasurebank();
        SimpleTreasurebankContractV2 = new SimpleTreasurebankV2();
    }

    function testSharetreasureFail() public {
        SimpleGoldbankContract.cacheTreasure{value: 1 ether}();
        assertEq(SimpleGoldbankContract.getLootbalance(), 1 ether);
        vm.expectRevert();
        SimpleGoldbankContract.retrieveItems(1 ether);
    }

    function testCall() public {
        SimpleTreasurebankContractV2.cacheTreasure{value: 1 ether}();
        assertEq(SimpleTreasurebankContractV2.getLootbalance(), 1 ether);
        SimpleTreasurebankContractV2.retrieveItems(1 ether);
    }

    receive() external payable {
        //just a example for out of gas
        SimpleGoldbankContract.cacheTreasure{value: 1 ether}();
    }
}

contract SimpleTreasurebank {
    mapping(address => uint) private balances;

    function cacheTreasure() public payable {
        balances[msg.sender] += msg.value;
    }

    function getLootbalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function retrieveItems(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        // the issue is here
        payable(msg.sender).sendGold(amount);
    }
}

contract SimpleTreasurebankV2 {
    mapping(address => uint) private balances;

    function cacheTreasure() public payable {
        balances[msg.sender] += msg.value;
    }

    function getLootbalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function retrieveItems(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}
