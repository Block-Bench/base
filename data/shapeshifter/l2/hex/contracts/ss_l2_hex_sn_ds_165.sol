pragma solidity ^0.4.0;

contract Governmental {
  address public _0xfc7371;
  address public _0x9aecaf;
  uint public _0x99e629 = 1 ether;
  uint public _0x67665a;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    _0xfc7371 = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function _0xa89bbe() {
    if (msg.value<_0x99e629/2) throw;
    _0x9aecaf = msg.sender;
    _0x99e629 += msg.value/2;
    _0x67665a = block.timestamp;
  }

  function _0x803485() {
    if (block.timestamp < _0x67665a+ONE_MINUTE)
      throw;

    _0x9aecaf.send(_0x99e629);
    _0xfc7371.send(this.balance-1 ether);

    _0x9aecaf = 0;
    _0x99e629 = 1 ether;
    _0x67665a = 0;
  }
}

contract Operator {

  function _0x671a7a(address _0x2477e2, uint _0xe23c35) {
    if (0<=_0xe23c35 && _0xe23c35<1023) {
      this._0x671a7a.gas(msg.gas-2000)(_0x2477e2, _0xe23c35+1);
    }
    else {
      Governmental(_0x2477e2)._0x803485();
    }
  }
}
