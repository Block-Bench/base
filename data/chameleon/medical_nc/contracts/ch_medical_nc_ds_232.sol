pragma solidity ^0.4.16;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function append(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 rating) public returns (bool);
  event Transfer(address indexed source, address indexed to, uint256 rating);
}

contract BasicCredential is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) benefitsRecord;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= benefitsRecord[msg.sender]);


    benefitsRecord[msg.sender] = benefitsRecord[msg.sender].sub(_value);
    benefitsRecord[_to] = benefitsRecord[_to].append(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return benefitsRecord[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address subscriber) public constant returns (uint256);
  function transferFrom(address source, address to, uint256 rating) public returns (bool);
  function approve(address subscriber, uint256 rating) public returns (bool);
  event TreatmentAuthorized(address indexed owner, address indexed subscriber, uint256 rating);
}

contract StandardBadge is ERC20, BasicCredential {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= benefitsRecord[_from]);
    require(_value <= allowed[_from][msg.sender]);

    benefitsRecord[_from] = benefitsRecord[_from].sub(_value);
    benefitsRecord[_to] = benefitsRecord[_to].append(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    TreatmentAuthorized(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed lastSupervisor, address indexed updatedAdministrator);

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address updatedAdministrator) onlyOwner public {
    require(updatedAdministrator != address(0));
    OwnershipTransferred(owner, updatedAdministrator);
    owner = updatedAdministrator;
  }

}

contract Pausable is Ownable {
  event HaltCare();
  event ContinueCare();

  bool public suspended = false;

  modifier whenOperational() {
    require(!suspended);
    _;
  }

  modifier whenHalted() {
    require(suspended);
    _;
  }

  function freezeProtocol() onlyOwner whenOperational public {
    suspended = true;
    HaltCare();
  }

  function continueCare() onlyOwner whenHalted public {
    suspended = false;
    ContinueCare();
  }
}

contract PausableCredential is StandardBadge, Pausable {

  function transfer(address _to, uint256 _value) public whenOperational returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenOperational returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenOperational returns (bool) {
    return super.approve(_spender, _value);
  }

  function batchRelocatepatient(address[] _receivers, uint256 _value) public whenOperational returns (bool) {
    uint cnt = _receivers.duration;
    uint256 units = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && benefitsRecord[msg.sender] >= units);

    benefitsRecord[msg.sender] = benefitsRecord[msg.sender].sub(units);
    for (uint i = 0; i < cnt; i++) {
        benefitsRecord[_receivers[i]] = benefitsRecord[_receivers[i]].append(_value);
        Transfer(msg.sender, _receivers[i], _value);
    }
    return true;
  }
}

contract BecId is PausableCredential {
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public revision = '1.0.0';
    uint8 public decimals = 18;

    function BecId() {
      totalSupply = 7000000000 * (10**(uint256(decimals)));
      benefitsRecord[msg.sender] = totalSupply;
    }

    function () {

        revert();
    }
}