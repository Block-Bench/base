// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract _0xa8fbd2 {
    address public _0x06847e;

    function _0xa8fbd2() public {
        if (true) { _0x06847e = msg.sender; }
    }

    modifier _0x41145a {
        require(msg.sender == _0x06847e);
        _;
    }

    function _0xbf07be(address _0x145588) _0x41145a public {
        _0x06847e = _0x145588;
    }
}

interface _0xf8b988 { function _0x21ed86(address _0x60b9e7, uint256 _0x6c7516, address _0x39dfc1, bytes _0xaa7b57) external; }

contract TokenERC20 {
    // Public variables of the token
    string public _0x039cc9;
    string public _0x749381;
    uint8 public _0xbe36c7 = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _0x50ed08;

    // This creates an array with all balances
    mapping (address => uint256) public _0xafb70b;
    mapping (address => mapping (address => uint256)) public _0x0e879a;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed _0xf5ef76, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _0x55dbcc, address indexed _0x44c86c, uint256 _0x6c7516);

    function TokenERC20(
        string _0xcdfff1,
        string _0x3022f5
    ) public {
        _0x039cc9 = _0xcdfff1;                                   // Set the name for display purposes
        _0x749381 = _0x3022f5;                               // Set the symbol for display purposes
    }

    function _0xa9fbfb(address _0x60b9e7, address _0xdc7326, uint _0x6c7516) internal {
        // Prevent transfer to 0x0 address.
        require(_0xdc7326 != 0x0);
        // Check if the sender has enough
        require(_0xafb70b[_0x60b9e7] >= _0x6c7516);

        require(_0xafb70b[_0xdc7326] + _0x6c7516 > _0xafb70b[_0xdc7326]);
        // Save this for an assertion in the future
        uint _0x08540c = _0xafb70b[_0x60b9e7] + _0xafb70b[_0xdc7326];
        // Subtract from the sender
        _0xafb70b[_0x60b9e7] -= _0x6c7516;
        // Add the same to the recipient
        _0xafb70b[_0xdc7326] += _0x6c7516;
        emit Transfer(_0x60b9e7, _0xdc7326, _0x6c7516);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(_0xafb70b[_0x60b9e7] + _0xafb70b[_0xdc7326] == _0x08540c);
    }

    function transfer(address _0xdc7326, uint256 _0x6c7516) public returns (bool _0x9aeaf1) {
        _0xa9fbfb(msg.sender, _0xdc7326, _0x6c7516);
        return true;
    }

    function _0xa06c9f(address _0x60b9e7, address _0xdc7326, uint256 _0x6c7516) public returns (bool _0x9aeaf1) {
        require(_0x6c7516 <= _0x0e879a[_0x60b9e7][msg.sender]);     // Check allowance
        _0x0e879a[_0x60b9e7][msg.sender] -= _0x6c7516;
        _0xa9fbfb(_0x60b9e7, _0xdc7326, _0x6c7516);
        return true;
    }

    function _0x012ebd(address _0x44c86c, uint256 _0x6c7516) public
        returns (bool _0x9aeaf1) {
        _0x0e879a[msg.sender][_0x44c86c] = _0x6c7516;
        emit Approval(msg.sender, _0x44c86c, _0x6c7516);
        return true;
    }

    function _0x1b6800(address _0x44c86c, uint256 _0x6c7516, bytes _0xaa7b57)
        public
        returns (bool _0x9aeaf1) {
        _0xf8b988 _0x1dc086 = _0xf8b988(_0x44c86c);
        if (_0x012ebd(_0x44c86c, _0x6c7516)) {
            _0x1dc086._0x21ed86(msg.sender, _0x6c7516, this, _0xaa7b57);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedToken is _0xa8fbd2, TokenERC20 {

    mapping (address => bool) public _0x8e6b7b;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address _0x8f271a, bool _0xfbfe0d);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedToken(
        string _0xcdfff1,
        string _0x3022f5
    ) TokenERC20(_0xcdfff1, _0x3022f5) public {}

    /* Internal transfer, only can be called by this contract */
    function _0xa9fbfb(address _0x60b9e7, address _0xdc7326, uint _0x6c7516) internal {
        require (_0xdc7326 != 0x0);                               // Prevent transfer to 0x0 address.
        require (_0xafb70b[_0x60b9e7] >= _0x6c7516);               // Check if the sender has enough
        require (_0xafb70b[_0xdc7326] + _0x6c7516 >= _0xafb70b[_0xdc7326]);
        require(!_0x8e6b7b[_0x60b9e7]);                     // Check if sender is frozen
        require(!_0x8e6b7b[_0xdc7326]);                       // Check if recipient is frozen
        _0xafb70b[_0x60b9e7] -= _0x6c7516;                         // Subtract from the sender
        _0xafb70b[_0xdc7326] += _0x6c7516;                           // Add the same to the recipient
        emit Transfer(_0x60b9e7, _0xdc7326, _0x6c7516);
    }

    /// @notice Buy tokens from contract by sending ether
    function _0x88a088() payable public {
        uint _0xf1ff9a = msg.value;                          // calculates the amount
	_0xafb70b[msg.sender] += _0xf1ff9a;                  // updates the balance
        _0x50ed08 += _0xf1ff9a;                            // updates the total supply
        _0xa9fbfb(address(0x0), msg.sender, _0xf1ff9a);      // makes the transfer
    }

    /* Migration function */
    function _0x1baa82() _0x41145a {
	assert(this.balance == _0x50ed08);                 // consistency check
	suicide(_0x06847e);                                      // transfer the ether to the owner and kill the contract
    }
}