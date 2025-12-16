pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleCoveragebank SimpleCoveragebankContract;
    SimpleCoveragebankV2 SimpleCoveragebankContractV2;

    function setUp() public {
        SimpleCoveragebankContract = new SimpleCoveragebank();
        SimpleCoveragebankContractV2 = new SimpleCoveragebankV2();
    }

    function testMovecoverageFail() public {
        SimpleCoveragebankContract.depositBenefit{value: 1 ether}();
        assertEq(SimpleCoveragebankContract.getCredits(), 1 ether);
        vm.expectRevert();
        SimpleCoveragebankContract.accessBenefit(1 ether);
    }

    function testCall() public {
        SimpleCoveragebankContractV2.depositBenefit{value: 1 ether}();
        assertEq(SimpleCoveragebankContractV2.getCredits(), 1 ether);
        SimpleCoveragebankContractV2.accessBenefit(1 ether);
    }

    receive() external payable {

        SimpleCoveragebankContract.depositBenefit{value: 1 ether}();
    }
}

contract SimpleCoveragebank {
    mapping(address => uint) private balances;

    function depositBenefit() public payable {
        balances[msg.sender] += msg.value;
    }

    function getCredits() public view returns (uint) {
        return balances[msg.sender];
    }

    function accessBenefit(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;

        payable(msg.sender).moveCoverage(amount);
    }
}

contract SimpleCoveragebankV2 {
    mapping(address => uint) private balances;

    function depositBenefit() public payable {
        balances[msg.sender] += msg.value;
    }

    function getCredits() public view returns (uint) {
        return balances[msg.sender];
    }

    function accessBenefit(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}