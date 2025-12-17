// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract owned {
    address public gamemaster;

    function owned() public {
        gamemaster = msg.sender;
    }

    modifier onlyDungeonmaster {
        require(msg.sender == gamemaster);
        _;
    }

    function tradelootOwnership(address newGamemaster) onlyDungeonmaster public {
        gamemaster = newGamemaster;
    }
}

interface goldtokenRecipient { function receiveApproval(address _from, uint256 _value, address _goldtoken, bytes _extraData) external; }

contract RealmcoinErc20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalGold;

    // This creates an array with all balances
    mapping (address => uint256) public gemtotalOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event ShareTreasure(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _gamemaster, address indexed _spender, uint256 _value);

    function RealmcoinErc20(
        string questtokenName,
        string realmcoinSymbol
    ) public {
        name = questtokenName;                                   // Set the name for display purposes
        symbol = realmcoinSymbol;                               // Set the symbol for display purposes
    }

    function _sharetreasure(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check if the sender has enough
        require(gemtotalOf[_from] >= _value);

        require(gemtotalOf[_to] + _value > gemtotalOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = gemtotalOf[_from] + gemtotalOf[_to];
        // Subtract from the sender
        gemtotalOf[_from] -= _value;
        // Add the same to the recipient
        gemtotalOf[_to] += _value;
        emit ShareTreasure(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(gemtotalOf[_from] + gemtotalOf[_to] == previousBalances);
    }

    function tradeLoot(address _to, uint256 _value) public returns (bool success) {
        _sharetreasure(msg.sender, _to, _value);
        return true;
    }

    function giveitemsFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _sharetreasure(_from, _to, _value);
        return true;
    }

    function permitTrade(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function authorizedealAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        goldtokenRecipient spender = goldtokenRecipient(_spender);
        if (permitTrade(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedQuesttoken is owned, RealmcoinErc20 {

    mapping (address => bool) public frozenGamerprofile;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedQuesttoken(
        string questtokenName,
        string realmcoinSymbol
    ) RealmcoinErc20(questtokenName, realmcoinSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _sharetreasure(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address.
        require (gemtotalOf[_from] >= _value);               // Check if the sender has enough
        require (gemtotalOf[_to] + _value >= gemtotalOf[_to]);
        require(!frozenGamerprofile[_from]);                     // Check if sender is frozen
        require(!frozenGamerprofile[_to]);                       // Check if recipient is frozen
        gemtotalOf[_from] -= _value;                         // Subtract from the sender
        gemtotalOf[_to] += _value;                           // Add the same to the recipient
        emit ShareTreasure(_from, _to, _value);
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value;                          // calculates the amount
	gemtotalOf[msg.sender] += amount;                  // updates the balance
        totalGold += amount;                            // updates the total supply
        _sharetreasure(address(0x0), msg.sender, amount);      // makes the transfer
    }

    /* Migration function */
    function migrate_and_destroy() onlyDungeonmaster {
	assert(this.goldHolding == totalGold);                 // consistency check
	suicide(gamemaster);                                      // transfer the ether to the owner and kill the contract
    }
}