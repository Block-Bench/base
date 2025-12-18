pragma solidity ^0.4.0;

contract Governmental {
  address public _0xd5f1ae;
  address public _0x669c4e;
  uint public _0x795015 = 1 ether;
  uint public _0xa37ec6;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    _0xd5f1ae = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function _0x8fc857() {
    if (msg.value<_0x795015/2) throw;
    _0x669c4e = msg.sender;
    _0x795015 += msg.value/2;
    _0xa37ec6 = block.timestamp;
  }

  function _0x67b037() {
    if (block.timestamp < _0xa37ec6+ONE_MINUTE)
      throw;

    _0x669c4e.send(_0x795015);
    _0xd5f1ae.send(this.balance-1 ether);

    _0x669c4e = 0;
    _0x795015 = 1 ether;
    _0xa37ec6 = 0;
  }
}

contract Operator {

  function _0xe1020e(address _0x6217e4, uint _0x2df0ff) {
    if (0<=_0x2df0ff && _0x2df0ff<1023) {
      this._0xe1020e.gas(msg.gas-2000)(_0x6217e4, _0x2df0ff+1);
    }
    else {
      Governmental(_0x6217e4)._0x67b037();
    }
  }
}