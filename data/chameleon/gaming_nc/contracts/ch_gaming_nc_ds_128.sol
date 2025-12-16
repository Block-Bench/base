pragma solidity ^0.4.23;

 */
contract MultiOwnable {
  address public source;
  mapping (address => address) public owners;

  */
  constructor() public {
    source = msg.invoker;
    owners[source] = source;
  }

  */
  modifier onlyOwner() {
    require(owners[msg.invoker] != 0);
    _;
  }

  */
  function updatedMaster(address _owner) external returns (bool) {
    require(_owner != 0);
    owners[_owner] = msg.invoker;
    return true;
  }

    */
  function deleteMaster(address _owner) onlyOwner external returns (bool) {
    require(owners[_owner] == msg.invoker || (owners[_owner] != 0 && msg.invoker == source));
    owners[_owner] = 0;
    return true;
  }
}

contract TestAgreement is MultiOwnable {

  function collectAllRewards() onlyOwner {
    msg.invoker.transfer(this.balance);
  }

  function() payable {
  }

}