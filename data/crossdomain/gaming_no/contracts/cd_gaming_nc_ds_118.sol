contract Destructible {
  address dungeonMaster;
  function suicide() public returns (address) {
    require(dungeonMaster == msg.sender);
    selfdestruct(dungeonMaster);
  }
}
contract C is Destructible {
  address dungeonMaster;
  function C() {
    dungeonMaster = msg.sender;
  }
}