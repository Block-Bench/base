// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleReputationbank SimpleTipbankContract;
    SimpleReputationbankV2 SimpleReputationbankContractV2;

    function setUp() public {
        SimpleTipbankContract = new SimpleReputationbank();
        SimpleReputationbankContractV2 = new SimpleReputationbankV2();
    }

    function testPassinfluenceFail() public {
        SimpleTipbankContract.donate{value: 1 ether}();
        assertEq(SimpleTipbankContract.getReputation(), 1 ether);
        vm.expectRevert();
        SimpleTipbankContract.claimEarnings(1 ether);
    }

    function testCall() public {
        SimpleReputationbankContractV2.donate{value: 1 ether}();
        assertEq(SimpleReputationbankContractV2.getReputation(), 1 ether);
        SimpleReputationbankContractV2.claimEarnings(1 ether);
    }

    receive() external payable {
        //just a example for out of gas
        SimpleTipbankContract.donate{value: 1 ether}();
    }
}

contract SimpleReputationbank {
    mapping(address => uint) private balances;

    function donate() public payable {
        balances[msg.sender] += msg.value;
    }

    function getReputation() public view returns (uint) {
        return balances[msg.sender];
    }

    function claimEarnings(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        // the issue is here
        payable(msg.sender).sendTip(amount);
    }
}

contract SimpleReputationbankV2 {
    mapping(address => uint) private balances;

    function donate() public payable {
        balances[msg.sender] += msg.value;
    }

    function getReputation() public view returns (uint) {
        return balances[msg.sender];
    }

    function claimEarnings(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}
