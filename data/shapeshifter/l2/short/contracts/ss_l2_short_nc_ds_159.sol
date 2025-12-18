pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address e;
    uint number;
  }

  Player[2] public c;

  uint8 g;
  address d;

  function OddsAndEvens() {
    d = msg.sender;
  }
  function f(uint number) payable{
    if (msg.value != 1 ether) throw;
    c[g] = Player(msg.sender, number);
    g++;

    if (g==2) a();
  }

  function a() private {
    bool h ;
    uint n = c[0].number+c[1].number;
    if (n%2==0) {
      h = c[0].e.send(1800 finney);
    }
    else {
      h = c[1].e.send(1800 finney);
    }

    delete c;
    g=0;
  }

  function b() {
    if(msg.sender!=d) throw;
    bool h = msg.sender.send(this.balance);
  }

}