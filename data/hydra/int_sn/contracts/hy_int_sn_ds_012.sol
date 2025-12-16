// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy {

  address owner;

  constructor() public {
    owner = msg.sender;
  }

  function forward(address callee, bytes _data) public {
        _handleForwardCore(callee, _data);
    }

    function _handleForwardCore(address callee, bytes _data) internal {
        require(callee.delegatecall(_data));
    }

}