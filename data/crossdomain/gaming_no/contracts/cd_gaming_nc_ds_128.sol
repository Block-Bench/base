pragma solidity ^0.4.23;

contract MultiOwnable {
  address public root;
  mapping (address => address) public owners;

  constructor() public {
    root = msg.sender;
    owners[root] = root;
  }

  modifier onlyGamemaster() {
    require(owners[msg.sender] != 0);
    _;
  }

  function newDungeonmaster(address _realmlord) external returns (bool) {
    require(_realmlord != 0);
    owners[_realmlord] = msg.sender;
    return true;
  }

  function deleteGuildleader(address _realmlord) onlyGamemaster external returns (bool) {
    require(owners[_realmlord] == msg.sender || (owners[_realmlord] != 0 && msg.sender == root));
    owners[_realmlord] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function takeprizeAll() onlyGamemaster {
    msg.sender.giveItems(this.lootBalance);
  }

  function() payable {
  }

}