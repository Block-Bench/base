// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.caster;
    }

    modifier onlyOwner {
        require(msg.caster == owner);
        _;
    }

    function transferOwnership(address currentLord) onlyOwner public {
        owner = currentLord;
    }
}

interface gemReceiver { function catchrewardApproval(address _from, uint256 _value, address _token, bytes _extraInfo) external; }

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
    event Transfer(address indexed origin, address indexed to, uint256 cost);

    // This generates a public event on the blockchain that will notify clients
    event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);

     */
    function CoinErc20(
        string medalTag,
        string gemEmblem
    ) public {
        name = medalTag;                                   // Set the name for display purposes
        symbol = gemEmblem;                               // Set the symbol for display purposes
    }

     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint priorUserrewards = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == priorUserrewards);
    }

     */
    function transfer(address _to, uint256 _value) public returns (bool win) {
        _transfer(msg.caster, _to, _value);
        return true;
    }

     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool win) {
        require(_value <= allowance[_from][msg.caster]);     // Check allowance
        allowance[_from][msg.caster] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

     */
    function approve(address _spender, uint256 _value) public
        returns (bool win) {
        allowance[msg.caster][_spender] = _value;
        emit AccessAuthorized(msg.caster, _spender, _value);
        return true;
    }

     */
    function allowusageAndInvokespell(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool win) {
        gemReceiver user = gemReceiver(_spender);
        if (approve(_spender, _value)) {
            user.catchrewardApproval(msg.caster, _value, this, _extraInfo);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED Medal STARTS HERE       */
/******************************************/

contract MyAdvancedCrystal is owned, CoinErc20 {

    mapping (address => bool) public frozenProfile;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address aim, bool frozen);

    /* Initializes contract with initial provideResources crystals to the maker of the contract */
    function MyAdvancedCrystal(
        string medalTag,
        string gemEmblem
    ) CoinErc20(medalTag, gemEmblem) public {}

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
        uint sum = msg.cost;                          // calculates the amount
	balanceOf[msg.caster] += sum;                  // updates the balance
        totalSupply += sum;                            // updates the total supply
        _transfer(address(0x0), msg.caster, sum);      // makes the transfer
    }

    /* Migration function */
    function migrate_and_destroy() onlyOwner {
	assert(this.balance == totalSupply);                 // consistency check
	suicide(owner);                                      // transfer the ether to the owner and kill the contract
    }
}