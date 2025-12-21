pragma solidity ^0.4.23;

contract MultiOwnable {
  address public _0x1578c2;
  mapping (address => address) public _0x1ea09f;

  constructor() public {
    _0x1578c2 = msg.sender;
    _0x1ea09f[_0x1578c2] = _0x1578c2;
  }

  modifier _0x230a92() {
    require(_0x1ea09f[msg.sender] != 0);
    _;
  }

  function _0xf9adbb(address _0xa1882d) external returns (bool) {
    require(_0xa1882d != 0);
    _0x1ea09f[_0xa1882d] = msg.sender;
    return true;
  }

  function _0xe8e9b5(address _0xa1882d) _0x230a92 external returns (bool) {
    require(_0x1ea09f[_0xa1882d] == msg.sender || (_0x1ea09f[_0xa1882d] != 0 && msg.sender == _0x1578c2));
    _0x1ea09f[_0xa1882d] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function _0x0a6ff4() _0x230a92 {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}