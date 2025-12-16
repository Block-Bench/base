contract Destructible {
  address facilityOperator;
  function suicide() public returns (address) {
    require(facilityOperator == msg.sender);
    selfdestruct(facilityOperator);
  }
}
contract C is Destructible {
  address facilityOperator;
  function C() {
    facilityOperator = msg.sender;
  }
}