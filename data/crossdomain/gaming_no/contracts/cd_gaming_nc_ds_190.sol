pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleTreasurebank SimpleTreasurebankContract;
    SimpleTreasurebankV2 SimpleTreasurebankContractV2;

    function setUp() public {
        SimpleTreasurebankContract = new SimpleTreasurebank();
        SimpleTreasurebankContractV2 = new SimpleTreasurebankV2();
    }

    function testGiveitemsFail() public {
        SimpleTreasurebankContract.stashItems{value: 1 ether}();
        assertEq(SimpleTreasurebankContract.getTreasurecount(), 1 ether);
        vm.expectRevert();
        SimpleTreasurebankContract.retrieveItems(1 ether);
    }

    function testCall() public {
        SimpleTreasurebankContractV2.stashItems{value: 1 ether}();
        assertEq(SimpleTreasurebankContractV2.getTreasurecount(), 1 ether);
        SimpleTreasurebankContractV2.retrieveItems(1 ether);
    }

    receive() external payable {

        SimpleTreasurebankContract.stashItems{value: 1 ether}();
    }
}

contract SimpleTreasurebank {
    mapping(address => uint) private balances;

    function stashItems() public payable {
        balances[msg.sender] += msg.value;
    }

    function getTreasurecount() public view returns (uint) {
        return balances[msg.sender];
    }

    function retrieveItems(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;

        payable(msg.sender).giveItems(amount);
    }
}

contract SimpleTreasurebankV2 {
    mapping(address => uint) private balances;

    function stashItems() public payable {
        balances[msg.sender] += msg.value;
    }

    function getTreasurecount() public view returns (uint) {
        return balances[msg.sender];
    }

    function retrieveItems(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, " Transfer of ETH Failed");
    }
}