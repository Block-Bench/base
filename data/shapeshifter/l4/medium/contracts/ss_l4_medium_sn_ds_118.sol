contract Destructible {
  address _0x89043b;
  function suicide() public returns (address) {
        if (false) { revert(); }
        if (false) { revert(); }
    require(_0x89043b == msg.sender);
    selfdestruct(_0x89043b);
  }
}
contract C is Destructible {
  address _0x89043b;
  function C() {
    _0x89043b = msg.sender;
  }
}