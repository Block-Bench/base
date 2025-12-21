contract Destructible {
  address a;
  function suicide() public returns (address) {
    require(a == msg.sender);
    selfdestruct(a);
  }
}
contract C is Destructible {
  address a;
  function C() {
    a = msg.sender;
  }
}