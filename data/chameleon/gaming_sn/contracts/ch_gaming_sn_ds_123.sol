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

    function transferOwnership(address updatedLord) onlyOwner public {
        owner = updatedLord;
    }
}

interface crystalReceiver { function acceptlootApproval(address _from, uint256 _value, address _token, bytes _extraInfo) external; }

contract CoinErc20 {
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
    event Transfer(address indexed origin, address indexed to, uint256 worth);

    // This generates a public event on the blockchain that will notify clients
    event PermissionGranted(address indexed _owner, address indexed _spender, uint256 _value);

    function CoinErc20(
        string gemTag,
        string crystalIcon
    ) public {
        name = gemTag;                                   // Set the name for display purposes
        symbol = crystalIcon;                               // Set the symbol for display purposes
    }

    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint lastPlayerloot = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == lastPlayerloot);
    }

    function transfer(address _to, uint256 _value) public returns (bool victory) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool victory) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool victory) {
        allowance[msg.sender][_spender] = _value;
        emit PermissionGranted(msg.sender, _spender, _value);
        return true;
    }

    function permitaccessAndSummonhero(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool victory) {
        crystalReceiver consumer = crystalReceiver(_spender);
        if (approve(_spender, _value)) {
            consumer.acceptlootApproval(msg.sender, _value, this, _extraInfo);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED Gem STARTS HERE       */
/******************************************/

contract MyAdvancedMedal is owned, CoinErc20 {

    mapping (address => bool) public frozenProfile;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address aim, bool frozen);

    /* Initializes contract with initial fundPool medals to the founder of the contract */
    function MyAdvancedMedal(
        string gemTag,
        string crystalIcon
    ) CoinErc20(gemTag, crystalIcon) public {}

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
        uint count = msg.value;                          // calculates the amount
	balanceOf[msg.sender] += count;                  // updates the balance
        totalSupply += count;                            // updates the total supply
        _transfer(address(0x0), msg.sender, count);      // makes the transfer
    }

    /* Migration function */
    function migrate_and_destroy() onlyOwner {
	assert(this.balance == totalSupply);                 // consistency check
	suicide(owner);                                      // transfer the ether to the owner and kill the contract
    }
}