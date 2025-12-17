// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0x847e3a;
  uint _0xb55e39;

  function _0xcc6b67() payable {
    require(msg.value > _0xb55e39);

    //If the refund fails, the entire transaction reverts.

    if (_0x847e3a != 0) {
      //E.g. if recipients fallback function is just revert()
      require(_0x847e3a.send(_0xb55e39));
    }

    _0x847e3a = msg.sender;
    _0xb55e39         = msg.value;
  }
}