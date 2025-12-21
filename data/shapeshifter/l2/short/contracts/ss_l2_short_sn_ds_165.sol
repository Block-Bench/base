pragma solidity ^0.4.0;

contract Governmental {
  address public i;
  address public c;
  uint public e = 1 ether;
  uint public a;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    i = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function f() {
    if (msg.value<e/2) throw;
    c = msg.sender;
    e += msg.value/2;
    a = block.timestamp;
  }

  function b() {
    if (block.timestamp < a+ONE_MINUTE)
      throw;

    c.send(e);
    i.send(this.balance-1 ether);

    c = 0;
    e = 1 ether;
    a = 0;
  }
}

contract Operator {

  function d(address g, uint h) {
    if (0<=h && h<1023) {
      this.d.gas(msg.gas-2000)(g, h+1);
    }
    else {
      Governmental(g).b();
    }
  }
}
