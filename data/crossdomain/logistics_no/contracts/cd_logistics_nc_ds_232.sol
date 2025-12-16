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
  uint256 public totalGoods;
  function stocklevelOf(address who) public constant returns (uint256);
  function moveGoods(address to, uint256 value) public returns (bool);
  event RelocateCargo(address indexed from, address indexed to, uint256 value);
}

contract BasicInventorytoken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function moveGoods(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);


    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    RelocateCargo(msg.sender, _to, _value);
    return true;
  }

  function stocklevelOf(address _facilityoperator) public constant returns (uint256 goodsOnHand) {
    return balances[_facilityoperator];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address depotOwner, address spender) public constant returns (uint256);
  function transferinventoryFrom(address from, address to, uint256 value) public returns (bool);
  function approveDispatch(address spender, uint256 value) public returns (bool);
  event Approval(address indexed depotOwner, address indexed spender, uint256 value);
}

contract StandardShipmenttoken is ERC20, BasicInventorytoken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferinventoryFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    RelocateCargo(_from, _to, _value);
    return true;
  }

  function approveDispatch(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _facilityoperator, address _spender) public constant returns (uint256 remaining) {
    return allowed[_facilityoperator][_spender];
  }
}

contract Ownable {
  address public depotOwner;

  event OwnershipTransferred(address indexed previousDepotowner, address indexed newLogisticsadmin);

  function Ownable() {
    depotOwner = msg.sender;
  }

  modifier onlyFacilityoperator() {
    require(msg.sender == depotOwner);
    _;
  }

  function relocatecargoOwnership(address newLogisticsadmin) onlyFacilityoperator public {
    require(newLogisticsadmin != address(0));
    OwnershipTransferred(depotOwner, newLogisticsadmin);
    depotOwner = newLogisticsadmin;
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

  function pause() onlyFacilityoperator whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyFacilityoperator whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableShipmenttoken is StandardShipmenttoken, Pausable {

  function moveGoods(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.moveGoods(_to, _value);
  }

  function transferinventoryFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferinventoryFrom(_from, _to, _value);
  }

  function approveDispatch(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approveDispatch(_spender, _value);
  }

  function batchTransferinventory(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    uint cnt = _receivers.length;
    uint256 amount = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && balances[msg.sender] >= amount);

    balances[msg.sender] = balances[msg.sender].sub(amount);
    for (uint i = 0; i < cnt; i++) {
        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
        RelocateCargo(msg.sender, _receivers[i], _value);
    }
    return true;
  }
}

contract BecCargotoken is PausableShipmenttoken {
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public version = '1.0.0';
    uint8 public decimals = 18;

    function BecCargotoken() {
      totalGoods = 7000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalGoods;
    }

    function () {

        revert();
    }
}