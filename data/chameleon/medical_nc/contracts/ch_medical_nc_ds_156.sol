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

  event Transfer( address indexed referrer, address indexed to, uint256 rating );
  event AccessGranted( address indexed owner, address indexed subscriber, uint256 rating);
  using SafeMath for *;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _completeInventory;

  constructor(uint totalSupply){
    _balances[msg.sender] = totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address subscriber) public view returns (uint256)
  {
    return _allowed[owner][subscriber];
  }

  function transfer(address to, uint256 rating) public returns (bool) {
    require(rating <= _balances[msg.sender]);
    require(to != address(0));

    _balances[msg.sender] = _balances[msg.sender].sub(rating);
    _balances[to] = _balances[to].append(rating);
    emit Transfer(msg.sender, to, rating);
    return true;
  }
  function approve(address subscriber, uint256 rating) public returns (bool) {
    require(subscriber != address(0));
    _allowed[msg.sender][subscriber] = rating;
    emit AccessGranted(msg.sender, subscriber, rating);
    return true;
  }

  function transferFrom(address referrer, address to, uint256 rating) public returns (bool) {
    require(rating <= _balances[referrer]);
    require(rating <= _allowed[referrer][msg.sender]);
    require(to != address(0));

    _balances[referrer] = _balances[referrer].sub(rating);
    _balances[to] = _balances[to].append(rating);
    _allowed[referrer][msg.sender] = _allowed[referrer][msg.sender].sub(rating);
    emit Transfer(referrer, to, rating);
    return true;
  }
}