contract Destructible {
  address _0x96ed8c;
  function suicide() public returns (address) {
    require(_0x96ed8c == msg.sender);
    selfdestruct(_0x96ed8c);
  }
}
contract C is Destructible {
  address _0x96ed8c;
  function C() {
    _0x96ed8c = msg.sender;
  }
}