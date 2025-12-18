pragma solidity ^0.4.23;

contract MultiOwnable {
  address public g;
  mapping (address => address) public f;

  constructor() public {
    g = msg.sender;
    f[g] = g;
  }

  modifier c() {
    require(f[msg.sender] != 0);
    _;
  }

  function d(address e) external returns (bool) {
    require(e != 0);
    f[e] = msg.sender;
    return true;
  }

  function b(address e) c external returns (bool) {
    require(f[e] == msg.sender || (f[e] != 0 && msg.sender == g));
    f[e] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function a() c {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}