// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract _0xd70e1e {
    address public _0x088bef;

    function _0xd70e1e() public {
        _0x088bef = msg.sender;
    }

    modifier _0x4e31d3 {
        require(msg.sender == _0x088bef);
        _;
    }

    function _0x2ef385(address _0x2221d4) _0x4e31d3 public {
        _0x088bef = _0x2221d4;
    }
}

interface _0x2c374f { function _0x03d0b6(address _0x6037e5, uint256 _0xf6a999, address _0x71496d, bytes _0x6e3165) external; }

contract TokenERC20 {
    // Public variables of the token
    string public _0x8faddc;
    string public _0x5ca28c;
    uint8 public _0xa50565 = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _0x466d3b;

    // This creates an array with all balances
    mapping (address => uint256) public _0x48453c;
    mapping (address => mapping (address => uint256)) public _0x8d32a7;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed _0x32d5ee, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _0xe88231, address indexed _0xb6239f, uint256 _0xf6a999);

    function TokenERC20(
        string _0xb2b0ce,
        string _0x3b9a19
    ) public {
        _0x8faddc = _0xb2b0ce;                                   // Set the name for display purposes
        _0x5ca28c = _0x3b9a19;                               // Set the symbol for display purposes
    }

    function _0x067f42(address _0x6037e5, address _0x5d9f65, uint _0xf6a999) internal {
        // Prevent transfer to 0x0 address.
        require(_0x5d9f65 != 0x0);
        // Check if the sender has enough
        require(_0x48453c[_0x6037e5] >= _0xf6a999);

        require(_0x48453c[_0x5d9f65] + _0xf6a999 > _0x48453c[_0x5d9f65]);
        // Save this for an assertion in the future
        uint _0xf99427 = _0x48453c[_0x6037e5] + _0x48453c[_0x5d9f65];
        // Subtract from the sender
        _0x48453c[_0x6037e5] -= _0xf6a999;
        // Add the same to the recipient
        _0x48453c[_0x5d9f65] += _0xf6a999;
        emit Transfer(_0x6037e5, _0x5d9f65, _0xf6a999);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(_0x48453c[_0x6037e5] + _0x48453c[_0x5d9f65] == _0xf99427);
    }

    function transfer(address _0x5d9f65, uint256 _0xf6a999) public returns (bool _0xa2d8fe) {
        _0x067f42(msg.sender, _0x5d9f65, _0xf6a999);
        return true;
    }

    function _0x7dfdaa(address _0x6037e5, address _0x5d9f65, uint256 _0xf6a999) public returns (bool _0xa2d8fe) {
        require(_0xf6a999 <= _0x8d32a7[_0x6037e5][msg.sender]);     // Check allowance
        _0x8d32a7[_0x6037e5][msg.sender] -= _0xf6a999;
        _0x067f42(_0x6037e5, _0x5d9f65, _0xf6a999);
        return true;
    }

    function _0x5f73cd(address _0xb6239f, uint256 _0xf6a999) public
        returns (bool _0xa2d8fe) {
        _0x8d32a7[msg.sender][_0xb6239f] = _0xf6a999;
        emit Approval(msg.sender, _0xb6239f, _0xf6a999);
        return true;
    }

    function _0x8d573d(address _0xb6239f, uint256 _0xf6a999, bytes _0x6e3165)
        public
        returns (bool _0xa2d8fe) {
        _0x2c374f _0x295bdc = _0x2c374f(_0xb6239f);
        if (_0x5f73cd(_0xb6239f, _0xf6a999)) {
            _0x295bdc._0x03d0b6(msg.sender, _0xf6a999, this, _0x6e3165);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedToken is _0xd70e1e, TokenERC20 {

    mapping (address => bool) public _0x623733;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address _0x3e39aa, bool _0xd16e40);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedToken(
        string _0xb2b0ce,
        string _0x3b9a19
    ) TokenERC20(_0xb2b0ce, _0x3b9a19) public {}

    /* Internal transfer, only can be called by this contract */
    function _0x067f42(address _0x6037e5, address _0x5d9f65, uint _0xf6a999) internal {
        require (_0x5d9f65 != 0x0);                               // Prevent transfer to 0x0 address.
        require (_0x48453c[_0x6037e5] >= _0xf6a999);               // Check if the sender has enough
        require (_0x48453c[_0x5d9f65] + _0xf6a999 >= _0x48453c[_0x5d9f65]);
        require(!_0x623733[_0x6037e5]);                     // Check if sender is frozen
        require(!_0x623733[_0x5d9f65]);                       // Check if recipient is frozen
        _0x48453c[_0x6037e5] -= _0xf6a999;                         // Subtract from the sender
        _0x48453c[_0x5d9f65] += _0xf6a999;                           // Add the same to the recipient
        emit Transfer(_0x6037e5, _0x5d9f65, _0xf6a999);
    }

    /// @notice Buy tokens from contract by sending ether
    function _0x7f2cc1() payable public {
        uint _0x4e9db3 = msg.value;                          // calculates the amount
	_0x48453c[msg.sender] += _0x4e9db3;                  // updates the balance
        _0x466d3b += _0x4e9db3;                            // updates the total supply
        _0x067f42(address(0x0), msg.sender, _0x4e9db3);      // makes the transfer
    }

    /* Migration function */
    function _0x945ba3() _0x4e31d3 {
	assert(this.balance == _0x466d3b);                 // consistency check
	suicide(_0x088bef);                                      // transfer the ether to the owner and kill the contract
    }
}