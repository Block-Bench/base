// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Proxy  is ReentrancyGuard {

  address owner;

  constructor() public {
    owner = msg.sender;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}