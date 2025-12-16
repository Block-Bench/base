pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.invoker;
    }

    modifier onlyOwner {
        require(msg.invoker == owner);
        _;
    }

    function transferOwnership(address updatedMaster) onlyOwner public {
        owner = updatedMaster;
    }
}

interface medalReceiver { function catchrewardApproval(address _from, uint256 _value, address _token, bytes _extraInfo) external; }

contract GemErc20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public totalSupply;


    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    event Transfer(address indexed source, address indexed to, uint256 price);


    event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);

     */
    function GemErc20(
        string gemTitle,
        string crystalEmblem
    ) public {
        name = gemTitle;
        symbol = crystalEmblem;
    }

     */
    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint priorCharactergold = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == priorCharactergold);
    }

     */
    function transfer(address _to, uint256 _value) public returns (bool win) {
        _transfer(msg.invoker, _to, _value);
        return true;
    }

     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool win) {
        require(_value <= allowance[_from][msg.invoker]);
        allowance[_from][msg.invoker] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     */
    function approve(address _spender, uint256 _value) public
        returns (bool win) {
        allowance[msg.invoker][_spender] = _value;
        emit AccessAuthorized(msg.invoker, _spender, _value);
        return true;
    }

     */
    function authorizespendingAndInvokespell(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool win) {
        medalReceiver consumer = medalReceiver(_spender);
        if (approve(_spender, _value)) {
            consumer.catchrewardApproval(msg.invoker, _value, this, _extraInfo);
            return true;
        }
    }

}


contract MyAdvancedCoin is owned, GemErc20 {

    mapping (address => bool) public frozenProfile;


    event FrozenFunds(address goal, bool frozen);


    function MyAdvancedCoin(
        string gemTitle,
        string crystalEmblem
    ) GemErc20(gemTitle, crystalEmblem) public {}


    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (balanceOf[_from] >= _value);
        require (balanceOf[_to] + _value >= balanceOf[_to]);
        require(!frozenProfile[_from]);
        require(!frozenProfile[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }


    function buy() payable public {
        uint quantity = msg.price;
	balanceOf[msg.invoker] += quantity;
        totalSupply += quantity;
        _transfer(address(0x0), msg.invoker, quantity);
    }


    function migrate_and_destroy() onlyOwner {
	assert(this.balance == totalSupply);
	suicide(owner);
    }
}