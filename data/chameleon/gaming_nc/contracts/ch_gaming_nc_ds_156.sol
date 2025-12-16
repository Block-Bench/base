pragma solidity ^0.4.24;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {


    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;


    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function append(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed origin, address indexed to, uint256 price );
  event PermissionGranted( address indexed owner, address indexed user, uint256 price);
  using SafeMath for *;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _completeReserve;

  constructor(uint totalSupply){
    _balances[msg.sender] = totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address user) public view returns (uint256)
  {
    return _allowed[owner][user];
  }

  function transfer(address to, uint256 price) public returns (bool) {
    require(price <= _balances[msg.sender]);
    require(to != address(0));

    _balances[msg.sender] = _balances[msg.sender].sub(price);
    _balances[to] = _balances[to].append(price);
    emit Transfer(msg.sender, to, price);
    return true;
  }
  function approve(address user, uint256 price) public returns (bool) {
    require(user != address(0));
    _allowed[msg.sender][user] = price;
    emit PermissionGranted(msg.sender, user, price);
    return true;
  }

  function transferFrom(address origin, address to, uint256 price) public returns (bool) {
    require(price <= _balances[origin]);
    require(price <= _allowed[origin][msg.sender]);
    require(to != address(0));

    _balances[origin] = _balances[origin].sub(price);
    _balances[to] = _balances[to].append(price);
    _allowed[origin][msg.sender] = _allowed[origin][msg.sender].sub(price);
    emit Transfer(origin, to, price);
    return true;
  }
}