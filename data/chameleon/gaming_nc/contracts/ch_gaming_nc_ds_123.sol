pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address updatedMaster) onlyOwner public {
        owner = updatedMaster;
    }
}

interface crystalTarget { function catchrewardApproval(address _from, uint256 _value, address _token, bytes _extraInfo) external; }

contract CrystalErc20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public totalSupply;


    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    event Transfer(address indexed origin, address indexed to, uint256 cost);


    event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);

    function CrystalErc20(
        string medalTag,
        string medalEmblem
    ) public {
        name = medalTag;
        symbol = medalEmblem;
    }

    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint priorPlayerloot = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == priorPlayerloot);
    }

    function transfer(address _to, uint256 _value) public returns (bool victory) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool victory) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool victory) {
        allowance[msg.sender][_spender] = _value;
        emit AccessAuthorized(msg.sender, _spender, _value);
        return true;
    }

    function authorizespendingAndInvokespell(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool victory) {
        crystalTarget user = crystalTarget(_spender);
        if (approve(_spender, _value)) {
            user.catchrewardApproval(msg.sender, _value, this, _extraInfo);
            return true;
        }
    }

}


contract MyAdvancedGem is owned, CrystalErc20 {

    mapping (address => bool) public frozenProfile;


    event FrozenFunds(address goal, bool frozen);


    function MyAdvancedGem(
        string medalTag,
        string medalEmblem
    ) CrystalErc20(medalTag, medalEmblem) public {}


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
        uint quantity = msg.value;
	balanceOf[msg.sender] += quantity;
        totalSupply += quantity;
        _transfer(address(0x0), msg.sender, quantity);
    }


    function migrate_and_destroy() onlyOwner {
	assert(this.balance == totalSupply);
	suicide(owner);
    }
}