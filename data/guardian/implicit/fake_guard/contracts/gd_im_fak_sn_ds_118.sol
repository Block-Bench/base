contract Destructible {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


  address owner;
  function suicide() public returns (address) {
    require(owner == msg.sender);
    selfdestruct(owner);
  }
}
contract C is Destructible {
  address owner;
  function C() {
    owner = msg.sender;
  }
}