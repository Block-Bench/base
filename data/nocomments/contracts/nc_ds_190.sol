pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract ContractTest is Test {
    SimpleBank SimpleBankContract;
    SimpleBankV2 SimpleBankContractV2;

    function setUp() public {
        SimpleBankContract = new SimpleBank();
        SimpleBankContractV2 = new SimpleBankV2();
    }

    function testTransferFail() public {
        SimpleBankContract.deposit{value: 1 ether}();
        assertEq(SimpleBankContract.getBalance(), 1 ether);
        vm.expectRevert();
        SimpleBankContract.withdraw(1 ether);
    }

    function testCall() public {
        SimpleBankContractV2.deposit{value: 1 ether}();
        assertEq(SimpleBankContractV2.getBalance(), 1 ether);
        SimpleBankContractV2.withdraw(1 ether);
    }

    receive() external payable {

        SimpleBankContract.deposit{value: 1 ether}();
    }
}

contract SimpleBank {
    mapping(address => uint) private balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);
    }
}

contract SimpleBankV2 {
    mapping(address => uint) private balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}