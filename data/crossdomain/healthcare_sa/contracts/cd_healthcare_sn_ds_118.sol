contract Destructible {
  address director;
  function suicide() public returns (address) {
    require(director == msg.sender);
    selfdestruct(director);
  }
}
contract C is Destructible {
  address director;
  function C() {
    director = msg.sender;
  }
}