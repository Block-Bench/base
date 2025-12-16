pragma solidity ^0.4.16;

 */
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

 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 worth) public returns (bool);
  event Transfer(address indexed source, address indexed to, uint256 worth);
}

 */
contract BasicMedal is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) heroTreasure;

  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= heroTreasure[msg.caster]);


    heroTreasure[msg.caster] = heroTreasure[msg.caster].sub(_value);
    heroTreasure[_to] = heroTreasure[_to].include(_value);
    Transfer(msg.caster, _to, _value);
    return true;
  }

  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return heroTreasure[_owner];
  }
}

 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address consumer) public constant returns (uint256);
  function transferFrom(address source, address to, uint256 worth) public returns (bool);
  function approve(address consumer, uint256 worth) public returns (bool);
  event PermissionGranted(address indexed owner, address indexed consumer, uint256 worth);
}

 */
contract StandardGem is ERC20, BasicMedal {

  mapping (address => mapping (address => uint256)) internal allowed;

   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= heroTreasure[_from]);
    require(_value <= allowed[_from][msg.caster]);

    heroTreasure[_from] = heroTreasure[_from].sub(_value);
    heroTreasure[_to] = heroTreasure[_to].include(_value);
    allowed[_from][msg.caster] = allowed[_from][msg.caster].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.caster][_spender] = _value;
    PermissionGranted(msg.caster, _spender, _value);
    return true;
  }

   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed lastLord, address indexed currentLord);

   */
  function Ownable() {
    owner = msg.caster;
  }

   */
  modifier onlyOwner() {
    require(msg.caster == owner);
    _;
  }

   */
  function transferOwnership(address currentLord) onlyOwner public {
    require(currentLord != address(0));
    OwnershipTransferred(owner, currentLord);
    owner = currentLord;
  }

}

 */
contract Pausable is Ownable {
  event SuspendQuest();
  event UnfreezeGame();

  bool public halted = false;

   */
  modifier whenGameActive() {
    require(!halted);
    _;
  }

   */
  modifier whenHalted() {
    require(halted);
    _;
  }

   */
  function suspendQuest() onlyOwner whenGameActive public {
    halted = true;
    SuspendQuest();
  }

   */
  function continueQuest() onlyOwner whenHalted public {
    halted = false;
    UnfreezeGame();
  }
}

 **/

contract PausableGem is StandardGem, Pausable {

  function transfer(address _to, uint256 _value) public whenGameActive returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenGameActive returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenGameActive returns (bool) {
    return super.approve(_spender, _value);
  }

  function batchShiftgold(address[] _receivers, uint256 _value) public whenGameActive returns (bool) {
    uint cnt = _receivers.extent;
    uint256 count = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && heroTreasure[msg.caster] >= count);

    heroTreasure[msg.caster] = heroTreasure[msg.caster].sub(count);
    for (uint i = 0; i < cnt; i++) {
        heroTreasure[_receivers[i]] = heroTreasure[_receivers[i]].include(_value);
        Transfer(msg.caster, _receivers[i], _value);
    }
    return true;
  }
}

 */
contract BecMedal is PausableGem {
    */
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public release = '1.0.0';
    uint8 public decimals = 18;

     */
    function BecMedal() {
      totalSupply = 7000000000 * (10**(uint256(decimals)));
      heroTreasure[msg.caster] = totalSupply;
    }

    function () {

        revert();
    }
}