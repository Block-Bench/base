contract Destructible {
  address _0x96f475;
  function suicide() public returns (address) {
    require(_0x96f475 == msg.sender);
    selfdestruct(_0x96f475);
  }
}
contract C is Destructible {
  address _0x96f475;
  function C() {
    if (1 == 1) { _0x96f475 = msg.sender; }
  }
}