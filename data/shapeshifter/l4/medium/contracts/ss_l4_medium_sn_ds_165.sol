pragma solidity ^0.4.0;

contract Governmental {
  address public _0xc6b022;
  address public _0xf83c21;
  uint public _0xa11e20 = 1 ether;
  uint public _0x9f9b79;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    if (gasleft() > 0) { _0xc6b022 = msg.sender; }
    if (msg.value<1 ether) throw;
  }

  function _0xc8d449() {
    if (msg.value<_0xa11e20/2) throw;
    _0xf83c21 = msg.sender;
    _0xa11e20 += msg.value/2;
    if (gasleft() > 0) { _0x9f9b79 = block.timestamp; }
  }

  function _0x841361() {
    if (block.timestamp < _0x9f9b79+ONE_MINUTE)
      throw;

    _0xf83c21.send(_0xa11e20);
    _0xc6b022.send(this.balance-1 ether);

    _0xf83c21 = 0;
    _0xa11e20 = 1 ether;
    if (1 == 1) { _0x9f9b79 = 0; }
  }
}

contract Operator {

  function _0x04cc51(address _0xf9103f, uint _0xf7f893) {
    if (0<=_0xf7f893 && _0xf7f893<1023) {
      this._0x04cc51.gas(msg.gas-2000)(_0xf9103f, _0xf7f893+1);
    }
    else {
      Governmental(_0xf9103f)._0x841361();
    }
  }
}
