// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
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
  uint256 public fundTotal;
  function coverageOf(address who) public constant returns (uint256);
  function moveCoverage(address to, uint256 value) public returns (bool);
  event MoveCoverage(address indexed from, address indexed to, uint256 value);
}

contract BasicCoveragetoken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function moveCoverage(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    MoveCoverage(msg.sender, _to, _value);
    return true;
  }

  function coverageOf(address _manager) public constant returns (uint256 benefits) {
    return balances[_manager];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address coordinator, address spender) public constant returns (uint256);
  function transferbenefitFrom(address from, address to, uint256 value) public returns (bool);
  function permitPayout(address spender, uint256 value) public returns (bool);
  event Approval(address indexed coordinator, address indexed spender, uint256 value);
}

contract StandardHealthtoken is ERC20, BasicCoveragetoken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferbenefitFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    MoveCoverage(_from, _to, _value);
    return true;
  }

  function permitPayout(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _manager, address _spender) public constant returns (uint256 remaining) {
    return allowed[_manager][_spender];
  }
}

contract Ownable {
  address public coordinator;

  event OwnershipTransferred(address indexed previousAdministrator, address indexed newSupervisor);

  function Ownable() {
    coordinator = msg.sender;
  }

  modifier onlyCoordinator() {
    require(msg.sender == coordinator);
    _;
  }

  function assigncreditOwnership(address newSupervisor) onlyCoordinator public {
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

  function pause() onlyCoordinator whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyCoordinator whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableHealthtoken is StandardHealthtoken, Pausable {

  function moveCoverage(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.moveCoverage(_to, _value);
  }

  function transferbenefitFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferbenefitFrom(_from, _to, _value);
  }

  function permitPayout(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.permitPayout(_spender, _value);
  }

  function batchMovecoverage(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
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

contract BecMedicalcredit is PausableHealthtoken {
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public version = '1.0.0';
    uint8 public decimals = 18;

    function BecMedicalcredit() {
      fundTotal = 7000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = fundTotal;    // Give the creator all initial tokens
    }

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}
