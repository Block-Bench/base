// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address a;
  uint b;

  function c() payable {
    require(msg.value > b);

    //If the refund fails, the entire transaction reverts.

    if (a != 0) {
      //E.g. if recipients fallback function is just revert()
      require(a.send(b));
    }

    a = msg.sender;
    b         = msg.value;
  }
}