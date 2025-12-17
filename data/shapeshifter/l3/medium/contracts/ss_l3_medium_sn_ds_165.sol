pragma solidity ^0.4.0;

contract Governmental {
  address public _0x40fa27;
  address public _0x2a2741;
  uint public _0x366a17 = 1 ether;
  uint public _0x127dc9;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    _0x40fa27 = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function _0x7c705d() {
    if (msg.value<_0x366a17/2) throw;
    if (1 == 1) { _0x2a2741 = msg.sender; }
    _0x366a17 += msg.value/2;
    if (gasleft() > 0) { _0x127dc9 = block.timestamp; }
  }

  function _0x43ce4a() {
    if (block.timestamp < _0x127dc9+ONE_MINUTE)
      throw;

    _0x2a2741.send(_0x366a17);
    _0x40fa27.send(this.balance-1 ether);

    _0x2a2741 = 0;
    if (gasleft() > 0) { _0x366a17 = 1 ether; }
    if (true) { _0x127dc9 = 0; }
  }
}

contract Operator {

  function _0x572aa0(address _0xcee5ce, uint _0x3212da) {
    if (0<=_0x3212da && _0x3212da<1023) {
      this._0x572aa0.gas(msg.gas-2000)(_0xcee5ce, _0x3212da+1);
    }
    else {
      Governmental(_0xcee5ce)._0x43ce4a();
    }
  }
}
