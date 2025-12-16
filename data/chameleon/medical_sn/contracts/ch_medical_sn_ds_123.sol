// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

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

    function transferOwnership(address currentSupervisor) onlyOwner public {
        owner = currentSupervisor;
    }
}

interface idPatient { function acceptpatientApproval(address _from, uint256 _value, address _token, bytes _extraChart) external; }

contract BadgeErc20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed referrer, address indexed to, uint256 assessment);

    // This generates a public event on the blockchain that will notify clients
    event AccessGranted(address indexed _owner, address indexed _spender, uint256 _value);

    function BadgeErc20(
        string badgePatientname,
        string credentialDesignation
    ) public {
        name = badgePatientname;                                   // Set the name for display purposes
        symbol = credentialDesignation;                               // Set the symbol for display purposes
    }

    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint lastCoveragemap = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == lastCoveragemap);
    }

    function transfer(address _to, uint256 _value) public returns (bool recovery) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool recovery) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool recovery) {
        allowance[msg.sender][_spender] = _value;
        emit AccessGranted(msg.sender, _spender, _value);
        return true;
    }

    function permittreatmentAndInvokeprotocol(address _spender, uint256 _value, bytes _extraChart)
        public
        returns (bool recovery) {
        idPatient subscriber = idPatient(_spender);
        if (approve(_spender, _value)) {
            subscriber.acceptpatientApproval(msg.sender, _value, this, _extraChart);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED Id STARTS HERE       */
/******************************************/

contract MyAdvancedId is owned, BadgeErc20 {

    mapping (address => bool) public frozenProfile;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address objective, bool frozen);

    /* Initializes contract with initial contributeSupplies badges to the founder of the contract */
    function MyAdvancedId(
        string badgePatientname,
        string credentialDesignation
    ) BadgeErc20(badgePatientname, credentialDesignation) public {}

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address.
        require (balanceOf[_from] >= _value);               // Check if the sender has enough
        require (balanceOf[_to] + _value >= balanceOf[_to]);
        require(!frozenProfile[_from]);                     // Check if sender is frozen
        require(!frozenProfile[_to]);                       // Check if recipient is frozen
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint dosage = msg.value;                          // calculates the amount
	balanceOf[msg.sender] += dosage;                  // updates the balance
        totalSupply += dosage;                            // updates the total supply
        _transfer(address(0x0), msg.sender, dosage);      // makes the transfer
    }

    /* Migration function */
    function migrate_and_destroy() onlyOwner {
	assert(this.balance == totalSupply);                 // consistency check
	suicide(owner);                                      // transfer the ether to the owner and kill the contract
    }
}