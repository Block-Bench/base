pragma solidity ^0.4.15;

contract SimpleAuction {
  address a;
  uint b;

  function f() payable {
    require(msg.value > b);


    if (a != 0) {

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


  function f() payable external {
    require(msg.value > b);

    if (a != 0) {
      d[a] += b;
    }

    a = msg.sender;
    b         = msg.value;
  }


  function c() external {

    uint e = d[msg.sender];
    d[msg.sender] = 0;

    msg.sender.send(e);
  }
}