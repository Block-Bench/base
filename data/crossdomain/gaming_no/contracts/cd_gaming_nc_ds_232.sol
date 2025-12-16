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
  uint256 public combinedLoot;
  function goldholdingOf(address who) public constant returns (uint256);
  function sendGold(address to, uint256 value) public returns (bool);
  event GiveItems(address indexed from, address indexed to, uint256 value);
}

contract BasicGoldtoken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function sendGold(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);


    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    GiveItems(msg.sender, _to, _value);
    return true;
  }

  function goldholdingOf(address _dungeonmaster) public constant returns (uint256 gemTotal) {
    return balances[_dungeonmaster];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address realmLord, address spender) public constant returns (uint256);
  function tradelootFrom(address from, address to, uint256 value) public returns (bool);
  function allowTransfer(address spender, uint256 value) public returns (bool);
  event Approval(address indexed realmLord, address indexed spender, uint256 value);
}

contract StandardQuesttoken is ERC20, BasicGoldtoken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function tradelootFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    GiveItems(_from, _to, _value);
    return true;
  }

  function allowTransfer(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _dungeonmaster, address _spender) public constant returns (uint256 remaining) {
    return allowed[_dungeonmaster][_spender];
  }
}

contract Ownable {
  address public realmLord;

  event OwnershipTransferred(address indexed previousRealmlord, address indexed newGuildleader);

  function Ownable() {
    realmLord = msg.sender;
  }

  modifier onlyDungeonmaster() {
    require(msg.sender == realmLord);
    _;
  }

  function giveitemsOwnership(address newGuildleader) onlyDungeonmaster public {
    require(newGuildleader != address(0));
    OwnershipTransferred(realmLord, newGuildleader);
    realmLord = newGuildleader;
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

  function pause() onlyDungeonmaster whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyDungeonmaster whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableQuesttoken is StandardQuesttoken, Pausable {

  function sendGold(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.sendGold(_to, _value);
  }

  function tradelootFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.tradelootFrom(_from, _to, _value);
  }

  function allowTransfer(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.allowTransfer(_spender, _value);
  }

  function batchTradeloot(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    uint cnt = _receivers.length;
    uint256 amount = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && balances[msg.sender] >= amount);

    balances[msg.sender] = balances[msg.sender].sub(amount);
    for (uint i = 0; i < cnt; i++) {
        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
        GiveItems(msg.sender, _receivers[i], _value);
    }
    return true;
  }
}

contract BecGamecoin is PausableQuesttoken {
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public version = '1.0.0';
    uint8 public decimals = 18;

    function BecGamecoin() {
      combinedLoot = 7000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = combinedLoot;
    }

    function () {

        revert();
    }
}