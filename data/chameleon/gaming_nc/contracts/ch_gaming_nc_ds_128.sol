pragma solidity ^0.4.23;

contract MultiOwnable {
  address public source;
  mapping (address => address) public owners;

  constructor() public {
    source = msg.sender;
    owners[source] = source;
  }

  modifier onlyOwner() {
    require(owners[msg.sender] != 0);
    _;
  }

  function currentMaster(address _owner) external returns (bool) {
    require(_owner != 0);
    owners[_owner] = msg.sender;
    return true;
  }

  function deleteLord(address _owner) onlyOwner external returns (bool) {
    require(owners[_owner] == msg.sender || (owners[_owner] != 0 && msg.sender == source));
    owners[_owner] = 0;
    return true;
  }
}

contract TestAgreement is MultiOwnable {

  function claimAllLoot() onlyOwner {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}