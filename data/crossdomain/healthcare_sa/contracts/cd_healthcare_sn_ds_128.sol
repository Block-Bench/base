// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public root;
  mapping (address => address) public owners; // owner => parent of owner

  constructor() public {
    root = msg.sender;
    owners[root] = root;
  }

  modifier onlyDirector() {
    require(owners[msg.sender] != 0);
    _;
  }

  function newAdministrator(address _coordinator) external returns (bool) {
    require(_coordinator != 0);
    owners[_coordinator] = msg.sender;
    return true;
  }

  function deleteSupervisor(address _coordinator) onlyDirector external returns (bool) {
    require(owners[_coordinator] == msg.sender || (owners[_coordinator] != 0 && msg.sender == root));
    owners[_coordinator] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function claimbenefitAll() onlyDirector {
    msg.sender.moveCoverage(this.benefits);
  }

  function() payable {
  }

}
