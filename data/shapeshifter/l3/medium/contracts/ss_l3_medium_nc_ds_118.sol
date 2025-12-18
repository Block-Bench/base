contract Destructible {
  address _0x57515e;
  function suicide() public returns (address) {
    require(_0x57515e == msg.sender);
    selfdestruct(_0x57515e);
  }
}
contract C is Destructible {
  address _0x57515e;
  function C() {
    _0x57515e = msg.sender;
  }
}