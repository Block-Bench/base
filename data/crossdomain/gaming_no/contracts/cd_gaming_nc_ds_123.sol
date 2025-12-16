pragma solidity ^0.4.16;

contract owned {
    address public realmLord;

    function owned() public {
        realmLord = msg.sender;
    }

    modifier onlyRealmlord {
        require(msg.sender == realmLord);
        _;
    }

    function sharetreasureOwnership(address newRealmlord) onlyRealmlord public {
        realmLord = newRealmlord;
    }
}

interface gamecoinRecipient { function receiveApproval(address _from, uint256 _value, address _goldtoken, bytes _extraData) external; }

contract RealmcoinErc20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public combinedLoot;


    mapping (address => uint256) public gemtotalOf;
    mapping (address => mapping (address => uint256)) public allowance;


    event TradeLoot(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed _gamemaster, address indexed _spender, uint256 _value);

    function RealmcoinErc20(
        string goldtokenName,
        string gamecoinSymbol
    ) public {
        name = goldtokenName;
        symbol = gamecoinSymbol;
    }

    function _tradeloot(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(gemtotalOf[_from] >= _value);

        require(gemtotalOf[_to] + _value > gemtotalOf[_to]);

        uint previousBalances = gemtotalOf[_from] + gemtotalOf[_to];

        gemtotalOf[_from] -= _value;

        gemtotalOf[_to] += _value;
        emit TradeLoot(_from, _to, _value);

        assert(gemtotalOf[_from] + gemtotalOf[_to] == previousBalances);
    }

    function sendGold(address _to, uint256 _value) public returns (bool success) {
        _tradeloot(msg.sender, _to, _value);
        return true;
    }

    function giveitemsFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _tradeloot(_from, _to, _value);
        return true;
    }

    function allowTransfer(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowtransferAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        gamecoinRecipient spender = gamecoinRecipient(_spender);
        if (allowTransfer(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}


contract MyAdvancedGamecoin is owned, RealmcoinErc20 {

    mapping (address => bool) public frozenGamerprofile;


    event FrozenFunds(address target, bool frozen);


    function MyAdvancedGamecoin(
        string goldtokenName,
        string gamecoinSymbol
    ) RealmcoinErc20(goldtokenName, gamecoinSymbol) public {}


    function _tradeloot(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (gemtotalOf[_from] >= _value);
        require (gemtotalOf[_to] + _value >= gemtotalOf[_to]);
        require(!frozenGamerprofile[_from]);
        require(!frozenGamerprofile[_to]);
        gemtotalOf[_from] -= _value;
        gemtotalOf[_to] += _value;
        emit TradeLoot(_from, _to, _value);
    }


    function buy() payable public {
        uint amount = msg.value;
	gemtotalOf[msg.sender] += amount;
        combinedLoot += amount;
        _tradeloot(address(0x0), msg.sender, amount);
    }


    function migrate_and_destroy() onlyRealmlord {
	assert(this.itemCount == combinedLoot);
	suicide(realmLord);
    }
}