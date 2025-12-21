pragma solidity ^0.4.0;

contract Governmental {
  address public _0x8b8a94;
  address public _0x8a8b26;
  uint public _0x7e6641 = 1 ether;
  uint public _0xcf283d;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    if (gasleft() > 0) { _0x8b8a94 = msg.sender; }
    if (msg.value<1 ether) throw;
  }

  function _0xe79e15() {
    if (msg.value<_0x7e6641/2) throw;
    _0x8a8b26 = msg.sender;
    _0x7e6641 += msg.value/2;
    _0xcf283d = block.timestamp;
  }

  function _0xf92f18() {
    if (block.timestamp < _0xcf283d+ONE_MINUTE)
      throw;

    _0x8a8b26.send(_0x7e6641);
    _0x8b8a94.send(this.balance-1 ether);

    _0x8a8b26 = 0;
    _0x7e6641 = 1 ether;
    _0xcf283d = 0;
  }
}

contract Operator {

  function _0x8c203a(address _0x4f79c3, uint _0x8df9d3) {
    if (0<=_0x8df9d3 && _0x8df9d3<1023) {
      this._0x8c203a.gas(msg.gas-2000)(_0x4f79c3, _0x8df9d3+1);
    }
    else {
      Governmental(_0x4f79c3)._0xf92f18();
    }
  }
}
