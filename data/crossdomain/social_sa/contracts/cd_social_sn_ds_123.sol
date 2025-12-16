// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract owned {
    address public moderator;

    function owned() public {
        moderator = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == moderator);
        _;
    }

    function givecreditOwnership(address newModerator) onlyAdmin public {
        moderator = newModerator;
    }
}

interface reputationtokenRecipient { function receiveApproval(address _from, uint256 _value, address _reputationtoken, bytes _extraData) external; }

contract InfluencetokenErc20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalKarma;

    // This creates an array with all balances
    mapping (address => uint256) public standingOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event PassInfluence(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _moderator, address indexed _spender, uint256 _value);

    function InfluencetokenErc20(
        string socialtokenName,
        string influencetokenSymbol
    ) public {
        name = socialtokenName;                                   // Set the name for display purposes
        symbol = influencetokenSymbol;                               // Set the symbol for display purposes
    }

    function _passinfluence(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check if the sender has enough
        require(standingOf[_from] >= _value);

        require(standingOf[_to] + _value > standingOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = standingOf[_from] + standingOf[_to];
        // Subtract from the sender
        standingOf[_from] -= _value;
        // Add the same to the recipient
        standingOf[_to] += _value;
        emit PassInfluence(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(standingOf[_from] + standingOf[_to] == previousBalances);
    }

    function giveCredit(address _to, uint256 _value) public returns (bool success) {
        _passinfluence(msg.sender, _to, _value);
        return true;
    }

    function sharekarmaFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _passinfluence(_from, _to, _value);
        return true;
    }

    function allowTip(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function authorizegiftAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        reputationtokenRecipient spender = reputationtokenRecipient(_spender);
        if (allowTip(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedSocialtoken is owned, InfluencetokenErc20 {

    mapping (address => bool) public frozenCreatoraccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedSocialtoken(
        string socialtokenName,
        string influencetokenSymbol
    ) InfluencetokenErc20(socialtokenName, influencetokenSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _passinfluence(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address.
        require (standingOf[_from] >= _value);               // Check if the sender has enough
        require (standingOf[_to] + _value >= standingOf[_to]);
        require(!frozenCreatoraccount[_from]);                     // Check if sender is frozen
        require(!frozenCreatoraccount[_to]);                       // Check if recipient is frozen
        standingOf[_from] -= _value;                         // Subtract from the sender
        standingOf[_to] += _value;                           // Add the same to the recipient
        emit PassInfluence(_from, _to, _value);
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value;                          // calculates the amount
	standingOf[msg.sender] += amount;                  // updates the balance
        totalKarma += amount;                            // updates the total supply
        _passinfluence(address(0x0), msg.sender, amount);      // makes the transfer
    }

    /* Migration function */
    function migrate_and_destroy() onlyAdmin {
	assert(this.karma == totalKarma);                 // consistency check
	suicide(moderator);                                      // transfer the ether to the owner and kill the contract
    }
}