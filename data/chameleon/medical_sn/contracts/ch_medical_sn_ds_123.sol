// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.provider;
    }

    modifier onlyOwner {
        require(msg.provider == owner);
        _;
    }

    function transferOwnership(address currentSupervisor) onlyOwner public {
        owner = currentSupervisor;
    }
}

interface idPatient { function acceptpatientApproval(address _from, uint256 _value, address _token, bytes _extraChart) external; }

contract CredentialErc20 {
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
    event Transfer(address indexed source, address indexed to, uint256 rating);

    // This generates a public event on the blockchain that will notify clients
    event AccessGranted(address indexed _owner, address indexed _spender, uint256 _value);

     */
    function CredentialErc20(
        string idPatientname,
        string credentialDesignation
    ) public {
        name = idPatientname;                                   // Set the name for display purposes
        symbol = credentialDesignation;                               // Set the symbol for display purposes
    }

     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint priorPatientaccounts = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == priorPatientaccounts);
    }

     */
    function transfer(address _to, uint256 _value) public returns (bool improvement) {
        _transfer(msg.provider, _to, _value);
        return true;
    }

     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool improvement) {
        require(_value <= allowance[_from][msg.provider]);     // Check allowance
        allowance[_from][msg.provider] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     */
    function approve(address _spender, uint256 _value) public
        returns (bool improvement) {
        allowance[msg.provider][_spender] = _value;
        emit AccessGranted(msg.provider, _spender, _value);
        return true;
    }

     */
    function authorizecaregiverAndConsultspecialist(address _spender, uint256 _value, bytes _extraChart)
        public
        returns (bool improvement) {
        idPatient subscriber = idPatient(_spender);
        if (approve(_spender, _value)) {
            subscriber.acceptpatientApproval(msg.provider, _value, this, _extraChart);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED Badge STARTS HERE       */
/******************************************/

contract MyAdvancedBadge is owned, CredentialErc20 {

    mapping (address => bool) public frozenProfile;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address goal, bool frozen);

    /* Initializes contract with initial provideResources ids to the author of the contract */
    function MyAdvancedBadge(
        string idPatientname,
        string credentialDesignation
    ) CredentialErc20(idPatientname, credentialDesignation) public {}

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
        uint quantity = msg.rating;                          // calculates the amount
	balanceOf[msg.provider] += quantity;                  // updates the balance
        totalSupply += quantity;                            // updates the total supply
        _transfer(address(0x0), msg.provider, quantity);      // makes the transfer
    }

    /* Migration function */
    function migrate_and_destroy() onlyOwner {
	assert(this.balance == totalSupply);                 // consistency check
	suicide(owner);                                      // transfer the ether to the owner and kill the contract
    }
}