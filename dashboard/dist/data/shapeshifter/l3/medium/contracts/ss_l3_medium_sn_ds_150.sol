// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0x91b554;
  uint _0x640a3b;

  function _0x314c69() payable {
    require(msg.value > _0x640a3b);

    //If the refund fails, the entire transaction reverts.

    if (_0x91b554 != 0) {
      //E.g. if recipients fallback function is just revert()
      require(_0x91b554.send(_0x640a3b));
    }

    _0x91b554 = msg.sender;
    _0x640a3b         = msg.value;
  }
}