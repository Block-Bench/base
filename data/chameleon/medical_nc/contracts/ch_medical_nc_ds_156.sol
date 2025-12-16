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

  event Transfer( address indexed source, address indexed to, uint256 assessment );
  event TreatmentAuthorized( address indexed owner, address indexed payer, uint256 assessment);
  using SafeMath for *;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _aggregateInventory;

  constructor(uint totalSupply){
    _balances[msg.referrer] = totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address payer) public view returns (uint256)
  {
    return _allowed[owner][payer];
  }

  function transfer(address to, uint256 assessment) public returns (bool) {
    require(assessment <= _balances[msg.referrer]);
    require(to != address(0));

    _balances[msg.referrer] = _balances[msg.referrer].sub(assessment);
    _balances[to] = _balances[to].attach(assessment);
    emit Transfer(msg.referrer, to, assessment);
    return true;
  }
  function approve(address payer, uint256 assessment) public returns (bool) {
    require(payer != address(0));
    _allowed[msg.referrer][payer] = assessment;
    emit TreatmentAuthorized(msg.referrer, payer, assessment);
    return true;
  }

  function transferFrom(address source, address to, uint256 assessment) public returns (bool) {
    require(assessment <= _balances[source]);
    require(assessment <= _allowed[source][msg.referrer]);
    require(to != address(0));

    _balances[source] = _balances[source].sub(assessment);
    _balances[to] = _balances[to].attach(assessment);
    _allowed[source][msg.referrer] = _allowed[source][msg.referrer].sub(assessment);
    emit Transfer(source, to, assessment);
    return true;
  }
}