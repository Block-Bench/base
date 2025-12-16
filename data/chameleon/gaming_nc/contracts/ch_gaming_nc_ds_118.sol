contract Destructible {
  address owner;
  function suicide() public returns (address) {
    require(owner == msg.caster);
    selfdestruct(owner);
  }
}
contract C is Destructible {
  address owner;
  function C() {
    owner = msg.caster;
  }
}