pragma solidity ^0.4.24;

library SafeMath {

  function k(uint256 a, uint256 b) internal pure returns (uint256) {


    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function o(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;


    return c;
  }

  function m(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function n(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function l(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed from, address indexed p, uint256 value );
  event Approval( address indexed j, address indexed i, uint256 value);
  using SafeMath for *;

  mapping (address => uint256) private f;

  mapping (address => mapping (address => uint256)) private g;

  uint256 private a;

  constructor(uint c){
    f[msg.sender] = c;
  }

  function e(address j) public view returns (uint256) {
    return f[j];
  }

  function d(address j, address i) public view returns (uint256)
  {
    return g[j][i];
  }

  function transfer(address p, uint256 value) public returns (bool) {
    require(value <= f[msg.sender]);
    require(p != address(0));

    f[msg.sender] = f[msg.sender].m(value);
    f[p] = f[p].n(value);
    emit Transfer(msg.sender, p, value);
    return true;
  }
  function h(address i, uint256 value) public returns (bool) {
    require(i != address(0));
    g[msg.sender][i] = value;
    emit Approval(msg.sender, i, value);
    return true;
  }

  function b(address from, address p, uint256 value) public returns (bool) {
    require(value <= f[from]);
    require(value <= g[from][msg.sender]);
    require(p != address(0));

    f[from] = f[from].m(value);
    f[p] = f[p].n(value);
    g[from][msg.sender] = g[from][msg.sender].m(value);
    emit Transfer(from, p, value);
    return true;
  }
}