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
  uint256 public pooledInfluence;
  function karmaOf(address who) public constant returns (uint256);
  function sendTip(address to, uint256 value) public returns (bool);
  event ShareKarma(address indexed from, address indexed to, uint256 value);
}

contract BasicReputationtoken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function sendTip(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);


    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    ShareKarma(msg.sender, _to, _value);
    return true;
  }

  function karmaOf(address _admin) public constant returns (uint256 standing) {
    return balances[_admin];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address founder, address spender) public constant returns (uint256);
  function givecreditFrom(address from, address to, uint256 value) public returns (bool);
  function permitTransfer(address spender, uint256 value) public returns (bool);
  event Approval(address indexed founder, address indexed spender, uint256 value);
}

contract StandardSocialtoken is ERC20, BasicReputationtoken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function givecreditFrom(address _from, address _to, uint256 _value) public returns (bool) {
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

  function allowance(address _admin, address _spender) public constant returns (uint256 remaining) {
    return allowed[_admin][_spender];
  }
}

contract Ownable {
  address public founder;

  event OwnershipTransferred(address indexed previousFounder, address indexed newCommunitylead);

  function Ownable() {
    founder = msg.sender;
  }

  modifier onlyAdmin() {
    require(msg.sender == founder);
    _;
  }

  function sharekarmaOwnership(address newCommunitylead) onlyAdmin public {
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

  function pause() onlyAdmin whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyAdmin whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableSocialtoken is StandardSocialtoken, Pausable {

  function sendTip(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.sendTip(_to, _value);
  }

  function givecreditFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.givecreditFrom(_from, _to, _value);
  }

  function permitTransfer(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.permitTransfer(_spender, _value);
  }

  function batchGivecredit(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
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

contract BecKarmatoken is PausableSocialtoken {
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public version = '1.0.0';
    uint8 public decimals = 18;

    function BecKarmatoken() {
      pooledInfluence = 7000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = pooledInfluence;
    }

    function () {

        revert();
    }
}