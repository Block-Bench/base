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

  function insert(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 evaluation) public returns (bool);
  event Transfer(address indexed source, address indexed to, uint256 evaluation);
}

 */
contract BasicCredential is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) patientAccounts;

  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= patientAccounts[msg.provider]);


    patientAccounts[msg.provider] = patientAccounts[msg.provider].sub(_value);
    patientAccounts[_to] = patientAccounts[_to].insert(_value);
    Transfer(msg.provider, _to, _value);
    return true;
  }

  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return patientAccounts[_owner];
  }
}

 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address subscriber) public constant returns (uint256);
  function transferFrom(address source, address to, uint256 evaluation) public returns (bool);
  function approve(address subscriber, uint256 evaluation) public returns (bool);
  event TreatmentAuthorized(address indexed owner, address indexed subscriber, uint256 evaluation);
}

 */
contract StandardId is ERC20, BasicCredential {

  mapping (address => mapping (address => uint256)) internal allowed;

   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= patientAccounts[_from]);
    require(_value <= allowed[_from][msg.provider]);

    patientAccounts[_from] = patientAccounts[_from].sub(_value);
    patientAccounts[_to] = patientAccounts[_to].insert(_value);
    allowed[_from][msg.provider] = allowed[_from][msg.provider].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.provider][_spender] = _value;
    TreatmentAuthorized(msg.provider, _spender, _value);
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

  event OwnershipTransferred(address indexed priorSupervisor, address indexed currentDirector);

   */
  function Ownable() {
    owner = msg.provider;
  }

   */
  modifier onlyOwner() {
    require(msg.provider == owner);
    _;
  }

   */
  function transferOwnership(address currentDirector) onlyOwner public {
    require(currentDirector != address(0));
    OwnershipTransferred(owner, currentDirector);
    owner = currentDirector;
  }

}

 */
contract Pausable is Ownable {
  event HaltCare();
  event ContinueCare();

  bool public halted = false;

   */
  modifier whenActive() {
    require(!halted);
    _;
  }

   */
  modifier whenHalted() {
    require(halted);
    _;
  }

   */
  function freezeProtocol() onlyOwner whenActive public {
    halted = true;
    HaltCare();
  }

   */
  function continueCare() onlyOwner whenHalted public {
    halted = false;
    ContinueCare();
  }
}

 **/

contract PausableId is StandardId, Pausable {

  function transfer(address _to, uint256 _value) public whenActive returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenActive returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenActive returns (bool) {
    return super.approve(_spender, _value);
  }

  function batchShiftcare(address[] _receivers, uint256 _value) public whenActive returns (bool) {
    uint cnt = _receivers.extent;
    uint256 measure = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && patientAccounts[msg.provider] >= measure);

    patientAccounts[msg.provider] = patientAccounts[msg.provider].sub(measure);
    for (uint i = 0; i < cnt; i++) {
        patientAccounts[_receivers[i]] = patientAccounts[_receivers[i]].insert(_value);
        Transfer(msg.provider, _receivers[i], _value);
    }
    return true;
  }
}

 */
contract BecId is PausableId {
    */
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public edition = '1.0.0';
    uint8 public decimals = 18;

     */
    function BecId() {
      totalSupply = 7000000000 * (10**(uint256(decimals)));
      patientAccounts[msg.provider] = totalSupply;
    }

    function () {

        revert();
    }
}