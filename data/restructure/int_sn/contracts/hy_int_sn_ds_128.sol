// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public root;
  mapping (address => address) public owners; // owner => parent of owner

  constructor() public {
    root = msg.sender;
    owners[root] = root;
  }

  modifier onlyOwner() {
    require(owners[msg.sender] != 0);
    _;
  }

  function newOwner(address _owner) external returns (bool) {
        return _handleNewOwnerInternal(msg.sender, _owner);
    }

    function _handleNewOwnerInternal(address _sender, address _owner) internal returns (bool) {
        require(_owner != 0);
        owners[_owner] = _sender;
        return true;
    }

  function deleteOwner(address _owner) onlyOwner external returns (bool) {
    require(owners[_owner] == msg.sender || (owners[_owner] != 0 && msg.sender == root));
    owners[_owner] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function withdrawAll() onlyOwner {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}
