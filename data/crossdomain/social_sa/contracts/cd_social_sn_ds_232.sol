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
  uint256 public allTips;
  function reputationOf(address who) public constant returns (uint256);
  function shareKarma(address to, uint256 value) public returns (bool);
  event ShareKarma(address indexed from, address indexed to, uint256 value);
}

contract BasicReputationtoken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function shareKarma(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    ShareKarma(msg.sender, _to, _value);
    return true;
  }

  function reputationOf(address _groupowner) public constant returns (uint256 karma) {
    return balances[_groupowner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address founder, address spender) public constant returns (uint256);
  function sendtipFrom(address from, address to, uint256 value) public returns (bool);
  function permitTransfer(address spender, uint256 value) public returns (bool);
  event Approval(address indexed founder, address indexed spender, uint256 value);
}

contract StandardKarmatoken is ERC20, BasicReputationtoken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function sendtipFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    ShareKarma(_from, _to, _value);
    return true;
  }

  function permitTransfer(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _groupowner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_groupowner][_spender];
  }
}

contract Ownable {
  address public founder;

  event OwnershipTransferred(address indexed previousModerator, address indexed newCommunitylead);

  function Ownable() {
    founder = msg.sender;
  }

  modifier onlyFounder() {
    require(msg.sender == founder);
    _;
  }

  function passinfluenceOwnership(address newCommunitylead) onlyFounder public {
    require(newCommunitylead != address(0));
    OwnershipTransferred(founder, newCommunitylead);
    founder = newCommunitylead;
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

  function pause() onlyFounder whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyFounder whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableKarmatoken is StandardKarmatoken, Pausable {

  function shareKarma(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.shareKarma(_to, _value);
  }

  function sendtipFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.sendtipFrom(_from, _to, _value);
  }

  function permitTransfer(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.permitTransfer(_spender, _value);
  }

  function batchSharekarma(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    uint cnt = _receivers.length;
    uint256 amount = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && balances[msg.sender] >= amount);

    balances[msg.sender] = balances[msg.sender].sub(amount);
    for (uint i = 0; i < cnt; i++) {
        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
        ShareKarma(msg.sender, _receivers[i], _value);
    }
    return true;
  }
}

contract BecInfluencetoken is PausableKarmatoken {
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public version = '1.0.0';
    uint8 public decimals = 18;

    function BecInfluencetoken() {
      allTips = 7000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = allTips;    // Give the creator all initial tokens
    }

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}
