pragma solidity ^0.8.18;
import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
contract ContractTest is Test {
SimpleBank SimpleBankContract;
SimpleBankV2 SimpleBankContractV2;
function setUp() public {
SimpleBankContract = new SimpleBank();
SimpleBankContractV2 = new SimpleBankV2();
}
function testAltDowncast() public {
SimpleBankContract.deposit(257);
console.log(
"balance of SimpleBankContract:",
SimpleBankContract.getBalance()
);
assertEq(SimpleBankContract.getBalance(), 1);
}
function testsafeDowncast() public {
vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
SimpleBankContractV2.deposit(257);
}
receive() external payable {}
}
contract SimpleBank {
mapping(address => uint) private balances;
function deposit(uint256 amount) public {
uint8 balance = uint8(amount);
balances[msg.sender] = balance;
}
function getBalance() public view returns (uint) {
return balances[msg.sender];
}
}
contract SimpleBankV2 {
using SafeCast for uint256;
mapping(address => uint) private balances;
function deposit(uint256 _amount) public {
uint8 amount = _amount.toUint8();
balances[msg.sender] = amount;
}
function getBalance() public view returns (uint) {
return balances[msg.sender];
}
}