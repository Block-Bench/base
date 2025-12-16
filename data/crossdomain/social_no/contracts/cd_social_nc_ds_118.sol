contract Destructible {
  address admin;
  function suicide() public returns (address) {
    require(admin == msg.sender);
    selfdestruct(admin);
  }
}
contract C is Destructible {
  address admin;
  function C() {
    admin = msg.sender;
  }
}