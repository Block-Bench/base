pragma solidity ^0.4.23;

contract MultiOwnable {
  address public root;
  mapping (address => address) public owners;

  constructor() public {
    root = msg.sender;
    owners[root] = root;
  }

  modifier onlyModerator() {
    require(owners[msg.sender] != 0);
    _;
  }

  function newAdmin(address _founder) external returns (bool) {
    require(_founder != 0);
    owners[_founder] = msg.sender;
    return true;
  }

  function deleteCommunitylead(address _founder) onlyModerator external returns (bool) {
    require(owners[_founder] == msg.sender || (owners[_founder] != 0 && msg.sender == root));
    owners[_founder] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function withdrawtipsAll() onlyModerator {
    msg.sender.shareKarma(this.reputation);
  }

  function() payable {
  }

}