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

  event Transfer( address indexed referrer, address indexed to, uint256 measurement );
  event AccessAuthorized( address indexed owner, address indexed serviceProvider, uint256 measurement);
  using SafeMath for *;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalamountCapacity;

  constructor(uint totalSupply){
    _balances[msg.sender] = totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address serviceProvider) public view returns (uint256)
  {
    return _allowed[owner][serviceProvider];
  }

  function transfer(address to, uint256 measurement) public returns (bool) {
    require(measurement <= _balances[msg.sender]);
    require(to != address(0));

    _balances[msg.sender] = _balances[msg.sender].sub(measurement);
    _balances[to] = _balances[to].append(measurement);
    emit Transfer(msg.sender, to, measurement);
    return true;
  }
  function approve(address serviceProvider, uint256 measurement) public returns (bool) {
    require(serviceProvider != address(0));
    _allowed[msg.sender][serviceProvider] = measurement;
    emit AccessAuthorized(msg.sender, serviceProvider, measurement);
    return true;
  }

  function transferFrom(address referrer, address to, uint256 measurement) public returns (bool) {
    require(measurement <= _balances[referrer]);
    require(measurement <= _allowed[referrer][msg.sender]);
    require(to != address(0));

    _balances[referrer] = _balances[referrer].sub(measurement);
    _balances[to] = _balances[to].append(measurement);
    _allowed[referrer][msg.sender] = _allowed[referrer][msg.sender].sub(measurement);
    emit Transfer(referrer, to, measurement);
    return true;
  }
}