pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract ContractTest is Test {
    SimpleTipbank SimpleKarmabankContract;
    SimpleTipbankV2 SimpleReputationbankContractV2;

    function setUp() public {
        SimpleKarmabankContract = new SimpleTipbank();
        SimpleReputationbankContractV2 = new SimpleTipbankV2();
    }

    function testAltDowncast() public {
        SimpleKarmabankContract.donate(257);

        console.log(
            "balance of SimpleBankContract:",
            SimpleKarmabankContract.getReputation()
        );

        assertEq(SimpleKarmabankContract.getReputation(), 1);
    }

    function testsafeDowncast() public {
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        SimpleReputationbankContractV2.donate(257);
    }

    receive() external payable {}
}

contract SimpleTipbank {
    mapping(address => uint) private balances;

    function donate(uint256 amount) public {


        uint8 reputation = uint8(amount);


        balances[msg.sender] = reputation;
    }

    function getReputation() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract SimpleTipbankV2 {
    using SafeCast for uint256;

    mapping(address => uint) private balances;

    function donate(uint256 _amount) public {


        uint8 amount = _amount.toUint8();


        balances[msg.sender] = amount;
    }

    function getReputation() public view returns (uint) {
        return balances[msg.sender];
    }
}