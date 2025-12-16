pragma solidity ^0.4.23;

contract MultiOwnable {
  address public root;
  mapping (address => address) public owners;

  constructor() public {
    root = msg.sender;
    owners[root] = root;
  }

  modifier onlyAdministrator() {
    require(owners[msg.sender] != 0);
    _;
  }

  function newDirector(address _coordinator) external returns (bool) {
    require(_coordinator != 0);
    owners[_coordinator] = msg.sender;
    return true;
  }

  function deleteSupervisor(address _coordinator) onlyAdministrator external returns (bool) {
    require(owners[_coordinator] == msg.sender || (owners[_coordinator] != 0 && msg.sender == root));
    owners[_coordinator] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function withdrawfundsAll() onlyAdministrator {
    msg.sender.moveCoverage(this.coverage);
  }

  function() payable {
  }

}