// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public root;
  mapping (address => address) public owners; // owner => parent of owner

  constructor() public {
    root = msg.sender;
    owners[root] = root;
  }

  modifier onlyDungeonmaster() {
    require(owners[msg.sender] != 0);
    _;
  }

  function newGamemaster(address _realmlord) external returns (bool) {
    require(_realmlord != 0);
    owners[_realmlord] = msg.sender;
    return true;
  }

  function deleteGuildleader(address _realmlord) onlyDungeonmaster external returns (bool) {
    require(owners[_realmlord] == msg.sender || (owners[_realmlord] != 0 && msg.sender == root));
    owners[_realmlord] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function claimlootAll() onlyDungeonmaster {
    msg.sender.giveItems(this.goldHolding);
  }

  function() payable {
  }

}
