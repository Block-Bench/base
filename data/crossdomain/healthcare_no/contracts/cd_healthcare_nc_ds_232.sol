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

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public reserveTotal;
  function benefitsOf(address who) public constant returns (uint256);
  function transferBenefit(address to, uint256 value) public returns (bool);
  event MoveCoverage(address indexed from, address indexed to, uint256 value);
}

contract BasicCoveragetoken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transferBenefit(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);


    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    MoveCoverage(msg.sender, _to, _value);
    return true;
  }

  function benefitsOf(address _director) public constant returns (uint256 allowance) {
    return balances[_director];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address coordinator, address spender) public constant returns (uint256);
  function sharebenefitFrom(address from, address to, uint256 value) public returns (bool);
  function validateClaim(address spender, uint256 value) public returns (bool);
  event Approval(address indexed coordinator, address indexed spender, uint256 value);
}

contract StandardBenefittoken is ERC20, BasicCoveragetoken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function sharebenefitFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    MoveCoverage(_from, _to, _value);
    return true;
  }

  function validateClaim(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _director, address _spender) public constant returns (uint256 remaining) {
    return allowed[_director][_spender];
  }
}

contract Ownable {
  address public coordinator;

  event OwnershipTransferred(address indexed previousCoordinator, address indexed newSupervisor);

  function Ownable() {
    coordinator = msg.sender;
  }

  modifier onlyDirector() {
    require(msg.sender == coordinator);
    _;
  }

  function movecoverageOwnership(address newSupervisor) onlyDirector public {
    require(newSupervisor != address(0));
    OwnershipTransferred(coordinator, newSupervisor);
    coordinator = newSupervisor;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyDirector whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyDirector whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableBenefittoken is StandardBenefittoken, Pausable {

  function transferBenefit(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferBenefit(_to, _value);
  }

  function sharebenefitFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.sharebenefitFrom(_from, _to, _value);
  }

  function validateClaim(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.validateClaim(_spender, _value);
  }

  function batchSharebenefit(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    uint cnt = _receivers.length;
    uint256 amount = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && balances[msg.sender] >= amount);

    balances[msg.sender] = balances[msg.sender].sub(amount);
    for (uint i = 0; i < cnt; i++) {
        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
        MoveCoverage(msg.sender, _receivers[i], _value);
    }
    return true;
  }
}

contract BecHealthtoken is PausableBenefittoken {
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public version = '1.0.0';
    uint8 public decimals = 18;

    function BecHealthtoken() {
      reserveTotal = 7000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = reserveTotal;
    }

    function () {

        revert();
    }
}