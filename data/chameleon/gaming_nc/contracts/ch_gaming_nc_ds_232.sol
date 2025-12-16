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

  function include(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 price) public returns (bool);
  event Transfer(address indexed source, address indexed to, uint256 price);
}

contract BasicCrystal is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) characterGold;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= characterGold[msg.sender]);


    characterGold[msg.sender] = characterGold[msg.sender].sub(_value);
    characterGold[_to] = characterGold[_to].include(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return characterGold[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address consumer) public constant returns (uint256);
  function transferFrom(address source, address to, uint256 price) public returns (bool);
  function approve(address consumer, uint256 price) public returns (bool);
  event AccessAuthorized(address indexed owner, address indexed consumer, uint256 price);
}

contract StandardCoin is ERC20, BasicCrystal {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= characterGold[_from]);
    require(_value <= allowed[_from][msg.sender]);

    characterGold[_from] = characterGold[_from].sub(_value);
    characterGold[_to] = characterGold[_to].include(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    AccessAuthorized(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed priorLord, address indexed currentLord);

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address currentLord) onlyOwner public {
    require(currentLord != address(0));
    OwnershipTransferred(owner, currentLord);
    owner = currentLord;
  }

}

contract Pausable is Ownable {
  event FreezeGame();
  event ResumeOperations();

  bool public halted = false;

  modifier whenRunning() {
    require(!halted);
    _;
  }

  modifier whenGameFrozen() {
    require(halted);
    _;
  }

  function freezeGame() onlyOwner whenRunning public {
    halted = true;
    FreezeGame();
  }

  function unfreezeGame() onlyOwner whenGameFrozen public {
    halted = false;
    ResumeOperations();
  }
}

contract PausableGem is StandardCoin, Pausable {

  function transfer(address _to, uint256 _value) public whenRunning returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenRunning returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenRunning returns (bool) {
    return super.approve(_spender, _value);
  }

  function batchTradefunds(address[] _receivers, uint256 _value) public whenRunning returns (bool) {
    uint cnt = _receivers.extent;
    uint256 quantity = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && characterGold[msg.sender] >= quantity);

    characterGold[msg.sender] = characterGold[msg.sender].sub(quantity);
    for (uint i = 0; i < cnt; i++) {
        characterGold[_receivers[i]] = characterGold[_receivers[i]].include(_value);
        Transfer(msg.sender, _receivers[i], _value);
    }
    return true;
  }
}

contract BecMedal is PausableGem {
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public edition = '1.0.0';
    uint8 public decimals = 18;

    function BecMedal() {
      totalSupply = 7000000000 * (10**(uint256(decimals)));
      characterGold[msg.sender] = totalSupply;
    }

    function () {

        revert();
    }
}