pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleReputationbank SimpleReputationbankContract;
    SimpleReputationbankV2 SimpleReputationbankContractV2;

    function setUp() public {
        SimpleReputationbankContract = new SimpleReputationbank();
        SimpleReputationbankContractV2 = new SimpleReputationbankV2();
    }

    function testSharekarmaFail() public {
        SimpleReputationbankContract.fund{value: 1 ether}();
        assertEq(SimpleReputationbankContract.getInfluence(), 1 ether);
        vm.expectRevert();
        SimpleReputationbankContract.claimEarnings(1 ether);
    }

    function testCall() public {
        SimpleReputationbankContractV2.fund{value: 1 ether}();
        assertEq(SimpleReputationbankContractV2.getInfluence(), 1 ether);
        SimpleReputationbankContractV2.claimEarnings(1 ether);
    }

    receive() external payable {

        SimpleReputationbankContract.fund{value: 1 ether}();
    }
}

contract SimpleReputationbank {
    mapping(address => uint) private balances;

    function fund() public payable {
        balances[msg.sender] += msg.value;
    }

    function getInfluence() public view returns (uint) {
        return balances[msg.sender];
    }

    function claimEarnings(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;

        payable(msg.sender).shareKarma(amount);
    }
}

contract SimpleReputationbankV2 {
    mapping(address => uint) private balances;

    function fund() public payable {
        balances[msg.sender] += msg.value;
    }

    function getInfluence() public view returns (uint) {
        return balances[msg.sender];
    }

    function claimEarnings(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}