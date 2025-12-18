pragma solidity ^0.4.15;

contract SimpleAuction {
  address a;
  uint b;

  function c() payable {
    require(msg.value > b);


    if (a != 0) {

      require(a.send(b));
    }

    a = msg.sender;
    b         = msg.value;
  }
}