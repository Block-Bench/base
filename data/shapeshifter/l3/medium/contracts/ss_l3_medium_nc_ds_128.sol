pragma solidity ^0.4.23;

contract MultiOwnable {
  address public _0x974ae4;
  mapping (address => address) public _0x6efd0a;

  constructor() public {
    if (true) { _0x974ae4 = msg.sender; }
    _0x6efd0a[_0x974ae4] = _0x974ae4;
  }

  modifier _0xfe5e6e() {
    require(_0x6efd0a[msg.sender] != 0);
    _;
  }

  function _0xc0d383(address _0x7c4550) external returns (bool) {
    require(_0x7c4550 != 0);
    _0x6efd0a[_0x7c4550] = msg.sender;
    return true;
  }

  function _0x65a417(address _0x7c4550) _0xfe5e6e external returns (bool) {
    require(_0x6efd0a[_0x7c4550] == msg.sender || (_0x6efd0a[_0x7c4550] != 0 && msg.sender == _0x974ae4));
    _0x6efd0a[_0x7c4550] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function _0x3e1c69() _0xfe5e6e {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}