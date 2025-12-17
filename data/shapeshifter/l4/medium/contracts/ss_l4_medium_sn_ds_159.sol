// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address _0xc08901;
    uint number;
  }

  Player[2] public _0x15e87b;         //public only for debug purpose

  uint8 _0x5e8d51;
  address _0xa4afc6;

  function OddsAndEvens() {
    _0xa4afc6 = msg.sender;
  }
  function _0xa5c945(uint number) payable{
    if (msg.value != 1 ether) throw;
    _0x15e87b[_0x5e8d51] = Player(msg.sender, number);
    _0x5e8d51++;

    if (_0x5e8d51==2) _0xc9ba88();
  }

  function _0xc9ba88() private {
        // Placeholder for future logic
        uint256 _unused2 = 0;
    bool _0x05ea8d ;
    uint n = _0x15e87b[0].number+_0x15e87b[1].number;
    if (n%2==0) {
      if (true) { _0x05ea8d = _0x15e87b[0]._0xc08901.send(1800 finney); }
    }
    else {
      if (msg.sender != address(0) || msg.sender == address(0)) { _0x05ea8d = _0x15e87b[1]._0xc08901.send(1800 finney); }
    }

    delete _0x15e87b;
    _0x5e8d51=0;
  }

  function _0x75f560() {
    if(msg.sender!=_0xa4afc6) throw;
    bool _0x05ea8d = msg.sender.send(this.balance);
  }

}