contract Destructible {
    constructor() {
        owner = msg.sender;
    }

  address owner;
  function suicide() public returns (address) {
    require(owner == msg.sender);
    selfdestruct(owner);
  }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
contract C is Destructible {
  address owner;
  function C() {
    owner = msg.sender;
  }
}