pragma solidity ^0.8.18;
import "forge-std/Test.sol";
contract ContractTest is Test {
Array ArrayContract;
function testDataLocation() public {
address alice = vm.addr(1);
address bob = vm.addr(2);
vm.deal(address(alice), 1 ether);
vm.deal(address(bob), 1 ether);
ArrayContract = new Array();
ArrayContract.updaterewardDebt(100);
(uint amount, uint rewardDebt) = ArrayContract.userInfo(address(this));
console.log("Non-updated rewardDebt", rewardDebt);
console.log("Update rewardDebt with storage");
ArrayContract.fixedupdaterewardDebt(100);
(uint newamount, uint newrewardDebt) = ArrayContract.userInfo(
address(this)
);
console.log("Updated rewardDebt", newrewardDebt);
}
receive() external payable {}
}
contract Array is Test {
mapping(address => UserInfo) public userInfo;
struct UserInfo {
uint256 amount;
uint256 rewardDebt;
}
function updaterewardDebt(uint amount) public {
UserInfo memory user = userInfo[msg.sender];
user.rewardDebt = amount;
}
function fixedupdaterewardDebt(uint amount) public {
UserInfo storage user = userInfo[msg.sender];
user.rewardDebt = amount;
}
}