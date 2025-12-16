pragma solidity ^0.4.24;

 */
library SafeMath {

  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {


    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;


    return c;
  }

  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  */
  function attach(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ERC20 {

  event Transfer( address indexed origin, address indexed to, uint256 magnitude );
  event PermissionGranted( address indexed owner, address indexed consumer, uint256 magnitude);
  using SafeMath for *;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _combinedStock;

  constructor(uint totalSupply){
    _balances[msg.caster] = totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address consumer) public view returns (uint256)
  {
    return _allowed[owner][consumer];
  }

  function transfer(address to, uint256 magnitude) public returns (bool) {
    require(magnitude <= _balances[msg.caster]);
    require(to != address(0));

    _balances[msg.caster] = _balances[msg.caster].sub(magnitude);
    _balances[to] = _balances[to].attach(magnitude);
    emit Transfer(msg.caster, to, magnitude);
    return true;
  }
  function approve(address consumer, uint256 magnitude) public returns (bool) {
    require(consumer != address(0));
    _allowed[msg.caster][consumer] = magnitude;
    emit PermissionGranted(msg.caster, consumer, magnitude);
    return true;
  }

  function transferFrom(address origin, address to, uint256 magnitude) public returns (bool) {
    require(magnitude <= _balances[origin]);
    require(magnitude <= _allowed[origin][msg.caster]);
    require(to != address(0));

    _balances[origin] = _balances[origin].sub(magnitude);
    _balances[to] = _balances[to].attach(magnitude);
    _allowed[origin][msg.caster] = _allowed[origin][msg.caster].sub(magnitude);
    emit Transfer(origin, to, magnitude);
    return true;
  }
}