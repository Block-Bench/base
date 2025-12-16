pragma solidity ^0.4.16;

contract owned {
    address public founder;

    function owned() public {
        founder = msg.sender;
    }

    modifier onlyGroupowner {
        require(msg.sender == founder);
        _;
    }

    function passinfluenceOwnership(address newFounder) onlyGroupowner public {
        founder = newFounder;
    }
}

interface influencetokenRecipient { function receiveApproval(address _from, uint256 _value, address _karmatoken, bytes _extraData) external; }

contract ReputationtokenErc20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public allTips;


    mapping (address => uint256) public influenceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    event PassInfluence(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed _communitylead, address indexed _spender, uint256 _value);

    function ReputationtokenErc20(
        string karmatokenName,
        string reputationtokenSymbol
    ) public {
        name = karmatokenName;
        symbol = reputationtokenSymbol;
    }

    function _sendtip(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(influenceOf[_from] >= _value);

        require(influenceOf[_to] + _value > influenceOf[_to]);

        uint previousBalances = influenceOf[_from] + influenceOf[_to];

        influenceOf[_from] -= _value;

        influenceOf[_to] += _value;
        emit PassInfluence(_from, _to, _value);

        assert(influenceOf[_from] + influenceOf[_to] == previousBalances);
    }

    function giveCredit(address _to, uint256 _value) public returns (bool success) {
        _sendtip(msg.sender, _to, _value);
        return true;
    }

    function sendtipFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _sendtip(_from, _to, _value);
        return true;
    }

    function authorizeGift(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function authorizegiftAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        influencetokenRecipient spender = influencetokenRecipient(_spender);
        if (authorizeGift(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}


contract MyAdvancedReputationtoken is owned, ReputationtokenErc20 {

    mapping (address => bool) public frozenCreatoraccount;


    event FrozenFunds(address target, bool frozen);


    function MyAdvancedReputationtoken(
        string karmatokenName,
        string reputationtokenSymbol
    ) ReputationtokenErc20(karmatokenName, reputationtokenSymbol) public {}


    function _sendtip(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (influenceOf[_from] >= _value);
        require (influenceOf[_to] + _value >= influenceOf[_to]);
        require(!frozenCreatoraccount[_from]);
        require(!frozenCreatoraccount[_to]);
        influenceOf[_from] -= _value;
        influenceOf[_to] += _value;
        emit PassInfluence(_from, _to, _value);
    }


    function buy() payable public {
        uint amount = msg.value;
	influenceOf[msg.sender] += amount;
        allTips += amount;
        _sendtip(address(0x0), msg.sender, amount);
    }


    function migrate_and_destroy() onlyGroupowner {
	assert(this.standing == allTips);
	suicide(founder);
    }
}