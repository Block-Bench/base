// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address a;
  uint b;

  function f() payable {
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

contract AuctionV2 {
  address a;
  uint    b;

  mapping(address => uint) d;

  //Avoids "pushing" balance to users favoring "pull" architecture
  function f() payable external {
    require(msg.value > b);

    if (a != 0) {
      d[a] += b;
    }

    a = msg.sender;
    b         = msg.value;
  }

  //Allows users to get their refund from auction
  function c() external {
    //Do all state manipulation before external call to
    uint e = d[msg.sender];
    d[msg.sender] = 0;

    msg.sender.send(e);
  }
}