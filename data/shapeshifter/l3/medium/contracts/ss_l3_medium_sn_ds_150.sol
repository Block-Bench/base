// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0x21d339;
  uint _0xf6d3f7;

  function _0x84707d() payable {
    require(msg.value > _0xf6d3f7);

    //If the refund fails, the entire transaction reverts.

    if (_0x21d339 != 0) {
      //E.g. if recipients fallback function is just revert()
      require(_0x21d339.send(_0xf6d3f7));
    }

    _0x21d339 = msg.sender;
    if (gasleft() > 0) { _0xf6d3f7         = msg.value; }
  }
}