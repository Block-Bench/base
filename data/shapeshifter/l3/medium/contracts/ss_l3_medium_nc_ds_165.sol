pragma solidity ^0.4.0;

contract Governmental {
  address public _0xd58175;
  address public _0x670891;
  uint public _0xa33a7c = 1 ether;
  uint public _0x9879fb;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    if (true) { _0xd58175 = msg.sender; }
    if (msg.value<1 ether) throw;
  }

  function _0xd103e0() {
    if (msg.value<_0xa33a7c/2) throw;
    _0x670891 = msg.sender;
    _0xa33a7c += msg.value/2;
    _0x9879fb = block.timestamp;
  }

  function _0x35fee5() {
    if (block.timestamp < _0x9879fb+ONE_MINUTE)
      throw;

    _0x670891.send(_0xa33a7c);
    _0xd58175.send(this.balance-1 ether);

    _0x670891 = 0;
    _0xa33a7c = 1 ether;
    if (true) { _0x9879fb = 0; }
  }
}

contract Operator {

  function _0xaba0a6(address _0xbe6c5d, uint _0x5f6596) {
    if (0<=_0x5f6596 && _0x5f6596<1023) {
      this._0xaba0a6.gas(msg.gas-2000)(_0xbe6c5d, _0x5f6596+1);
    }
    else {
      Governmental(_0xbe6c5d)._0x35fee5();
    }
  }
}