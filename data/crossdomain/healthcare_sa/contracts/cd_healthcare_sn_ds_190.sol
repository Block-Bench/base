// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleCoveragebank SimpleHealthbankContract;
    SimpleCoveragebankV2 SimpleCoveragebankContractV2;

    function setUp() public {
        SimpleHealthbankContract = new SimpleCoveragebank();
        SimpleCoveragebankContractV2 = new SimpleCoveragebankV2();
    }

    function testAssigncreditFail() public {
        SimpleHealthbankContract.fundAccount{value: 1 ether}();
        assertEq(SimpleHealthbankContract.getCoverage(), 1 ether);
        vm.expectRevert();
        SimpleHealthbankContract.accessBenefit(1 ether);
    }

    function testCall() public {
        SimpleCoveragebankContractV2.fundAccount{value: 1 ether}();
        assertEq(SimpleCoveragebankContractV2.getCoverage(), 1 ether);
        SimpleCoveragebankContractV2.accessBenefit(1 ether);
    }

    receive() external payable {
        //just a example for out of gas
        SimpleHealthbankContract.fundAccount{value: 1 ether}();
    }
}

contract SimpleCoveragebank {
    mapping(address => uint) private balances;

    function fundAccount() public payable {
        balances[msg.sender] += msg.value;
    }

    function getCoverage() public view returns (uint) {
        return balances[msg.sender];
    }

    function accessBenefit(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        // the issue is here
        payable(msg.sender).transferBenefit(amount);
    }
}

contract SimpleCoveragebankV2 {
    mapping(address => uint) private balances;

    function fundAccount() public payable {
        balances[msg.sender] += msg.value;
    }

    function getCoverage() public view returns (uint) {
        return balances[msg.sender];
    }

    function accessBenefit(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}
