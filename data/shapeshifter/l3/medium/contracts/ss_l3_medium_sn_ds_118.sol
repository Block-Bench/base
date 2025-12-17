contract Destructible {
  address _0x41a7c1;
  function suicide() public returns (address) {
    require(_0x41a7c1 == msg.sender);
    selfdestruct(_0x41a7c1);
  }
}
contract C is Destructible {
  address _0x41a7c1;
  function C() {
    _0x41a7c1 = msg.sender;
  }
}