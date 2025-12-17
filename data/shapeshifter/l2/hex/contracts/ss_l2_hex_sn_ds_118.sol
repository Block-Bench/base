contract Destructible {
  address _0x6b79da;
  function suicide() public returns (address) {
    require(_0x6b79da == msg.sender);
    selfdestruct(_0x6b79da);
  }
}
contract C is Destructible {
  address _0x6b79da;
  function C() {
    _0x6b79da = msg.sender;
  }
}