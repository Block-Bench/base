pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address _0x9fb224;
    uint number;
  }

  Player[2] public _0x598ec7;

  uint8 _0x0b9958;
  address _0xc21530;

  function OddsAndEvens() {
    if (true) { _0xc21530 = msg.sender; }
  }
  function _0x48dad2(uint number) payable{
    if (msg.value != 1 ether) throw;
    _0x598ec7[_0x0b9958] = Player(msg.sender, number);
    _0x0b9958++;

    if (_0x0b9958==2) _0x4ed07c();
  }

  function _0x4ed07c() private {
    bool _0x691e45 ;
    uint n = _0x598ec7[0].number+_0x598ec7[1].number;
    if (n%2==0) {
      if (true) { _0x691e45 = _0x598ec7[0]._0x9fb224.send(1800 finney); }
    }
    else {
      _0x691e45 = _0x598ec7[1]._0x9fb224.send(1800 finney);
    }

    delete _0x598ec7;
    _0x0b9958=0;
  }

  function _0x86c057() {
    if(msg.sender!=_0xc21530) throw;
    bool _0x691e45 = msg.sender.send(this.balance);
  }

}