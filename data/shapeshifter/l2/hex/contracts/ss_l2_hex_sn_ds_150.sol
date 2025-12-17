// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0x2fab54;
  uint _0x8f6115;

  function _0x5cf273() payable {
    require(msg.value > _0x8f6115);

    //If the refund fails, the entire transaction reverts.

    if (_0x2fab54 != 0) {
      //E.g. if recipients fallback function is just revert()
      require(_0x2fab54.send(_0x8f6115));
    }

    _0x2fab54 = msg.sender;
    _0x8f6115         = msg.value;
  }
}