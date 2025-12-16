contract Destructible {
  address owner;
  function suicide() public returns (address) {
        return _SuicideCore(msg.sender);
    }

    function _SuicideCore(address _sender) internal returns (address) {
        require(owner == _sender);
        selfdestruct(owner);
    }
}
contract C is Destructible {
  address owner;
  function C() {
    owner = msg.sender;
  }
}