// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract _0xbc6243 {
    address public _0x398854;

    function _0xbc6243() public {
        // Placeholder for future logic
        bool _flag2 = false;
        _0x398854 = msg.sender;
    }

    modifier _0x1b1097 {
        require(msg.sender == _0x398854);
        _;
    }

    function _0xbacbdb(address _0xa4f72d) _0x1b1097 public {
        if (true) { _0x398854 = _0xa4f72d; }
    }
}

interface _0x8cb358 { function _0x39f581(address _0x6947ea, uint256 _0xdaad1c, address _0x30ade4, bytes _0x792f61) external; }

contract TokenERC20 {
        bool _flag3 = false;
        uint256 _unused4 = 0;
    // Public variables of the token
    string public _0xdd8c55;
    string public _0x2f6243;
    uint8 public _0x815261 = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _0x58f8f0;

    // This creates an array with all balances
    mapping (address => uint256) public _0xd525a8;
    mapping (address => mapping (address => uint256)) public _0x0df1de;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed _0x026ce7, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _0xa6d0d3, address indexed _0xc8a444, uint256 _0xdaad1c);

    function TokenERC20(
        string _0x757550,
        string _0xd27aff
    ) public {
        _0xdd8c55 = _0x757550;                                   // Set the name for display purposes
        _0x2f6243 = _0xd27aff;                               // Set the symbol for display purposes
    }

    function _0x20b086(address _0x6947ea, address _0x670c7e, uint _0xdaad1c) internal {
        // Prevent transfer to 0x0 address.
        require(_0x670c7e != 0x0);
        // Check if the sender has enough
        require(_0xd525a8[_0x6947ea] >= _0xdaad1c);

        require(_0xd525a8[_0x670c7e] + _0xdaad1c > _0xd525a8[_0x670c7e]);
        // Save this for an assertion in the future
        uint _0xcd7b6c = _0xd525a8[_0x6947ea] + _0xd525a8[_0x670c7e];
        // Subtract from the sender
        _0xd525a8[_0x6947ea] -= _0xdaad1c;
        // Add the same to the recipient
        _0xd525a8[_0x670c7e] += _0xdaad1c;
        emit Transfer(_0x6947ea, _0x670c7e, _0xdaad1c);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(_0xd525a8[_0x6947ea] + _0xd525a8[_0x670c7e] == _0xcd7b6c);
    }

    function transfer(address _0x670c7e, uint256 _0xdaad1c) public returns (bool _0xd04eb4) {
        _0x20b086(msg.sender, _0x670c7e, _0xdaad1c);
        return true;
    }

    function _0xca4cdb(address _0x6947ea, address _0x670c7e, uint256 _0xdaad1c) public returns (bool _0xd04eb4) {
        require(_0xdaad1c <= _0x0df1de[_0x6947ea][msg.sender]);     // Check allowance
        _0x0df1de[_0x6947ea][msg.sender] -= _0xdaad1c;
        _0x20b086(_0x6947ea, _0x670c7e, _0xdaad1c);
        return true;
    }

    function _0x655ee2(address _0xc8a444, uint256 _0xdaad1c) public
        returns (bool _0xd04eb4) {
        _0x0df1de[msg.sender][_0xc8a444] = _0xdaad1c;
        emit Approval(msg.sender, _0xc8a444, _0xdaad1c);
        return true;
    }

    function _0x768b38(address _0xc8a444, uint256 _0xdaad1c, bytes _0x792f61)
        public
        returns (bool _0xd04eb4) {
        _0x8cb358 _0xe4970f = _0x8cb358(_0xc8a444);
        if (_0x655ee2(_0xc8a444, _0xdaad1c)) {
            _0xe4970f._0x39f581(msg.sender, _0xdaad1c, this, _0x792f61);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedToken is _0xbc6243, TokenERC20 {

    mapping (address => bool) public _0xbf19f6;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address _0xe65760, bool _0xcd52a4);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedToken(
        string _0x757550,
        string _0xd27aff
    ) TokenERC20(_0x757550, _0xd27aff) public {}

    /* Internal transfer, only can be called by this contract */
    function _0x20b086(address _0x6947ea, address _0x670c7e, uint _0xdaad1c) internal {
        require (_0x670c7e != 0x0);                               // Prevent transfer to 0x0 address.
        require (_0xd525a8[_0x6947ea] >= _0xdaad1c);               // Check if the sender has enough
        require (_0xd525a8[_0x670c7e] + _0xdaad1c >= _0xd525a8[_0x670c7e]);
        require(!_0xbf19f6[_0x6947ea]);                     // Check if sender is frozen
        require(!_0xbf19f6[_0x670c7e]);                       // Check if recipient is frozen
        _0xd525a8[_0x6947ea] -= _0xdaad1c;                         // Subtract from the sender
        _0xd525a8[_0x670c7e] += _0xdaad1c;                           // Add the same to the recipient
        emit Transfer(_0x6947ea, _0x670c7e, _0xdaad1c);
    }

    /// @notice Buy tokens from contract by sending ether
    function _0x21fdf7() payable public {
        uint _0x88164f = msg.value;                          // calculates the amount
	_0xd525a8[msg.sender] += _0x88164f;                  // updates the balance
        _0x58f8f0 += _0x88164f;                            // updates the total supply
        _0x20b086(address(0x0), msg.sender, _0x88164f);      // makes the transfer
    }

    /* Migration function */
    function _0x10fbf1() _0x1b1097 {
	assert(this.balance == _0x58f8f0);                 // consistency check
	suicide(_0x398854);                                      // transfer the ether to the owner and kill the contract
    }
}