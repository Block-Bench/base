// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract _0xcab1f9 {
    address public _0xbca527;

    function _0xcab1f9() public {
        _0xbca527 = msg.sender;
    }

    modifier _0xb6d993 {
        require(msg.sender == _0xbca527);
        _;
    }

    function _0x30737c(address _0x8d0488) _0xb6d993 public {
        _0xbca527 = _0x8d0488;
    }
}

interface _0x144455 { function _0x0da219(address _0x678723, uint256 _0x870650, address _0x7b6a85, bytes _0xfdbcdc) external; }

contract TokenERC20 {
    // Public variables of the token
    string public _0x9151e2;
    string public _0xf97963;
    uint8 public _0xe23051 = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _0x17853b;

    // This creates an array with all balances
    mapping (address => uint256) public _0xf6f353;
    mapping (address => mapping (address => uint256)) public _0xae75bb;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed _0x3ca2f7, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _0x18f618, address indexed _0xd535b2, uint256 _0x870650);

    function TokenERC20(
        string _0x092f76,
        string _0xa5dc5b
    ) public {
        _0x9151e2 = _0x092f76;                                   // Set the name for display purposes
        _0xf97963 = _0xa5dc5b;                               // Set the symbol for display purposes
    }

    function _0xbd8074(address _0x678723, address _0x6dc6eb, uint _0x870650) internal {
        // Prevent transfer to 0x0 address.
        require(_0x6dc6eb != 0x0);
        // Check if the sender has enough
        require(_0xf6f353[_0x678723] >= _0x870650);

        require(_0xf6f353[_0x6dc6eb] + _0x870650 > _0xf6f353[_0x6dc6eb]);
        // Save this for an assertion in the future
        uint _0x737275 = _0xf6f353[_0x678723] + _0xf6f353[_0x6dc6eb];
        // Subtract from the sender
        _0xf6f353[_0x678723] -= _0x870650;
        // Add the same to the recipient
        _0xf6f353[_0x6dc6eb] += _0x870650;
        emit Transfer(_0x678723, _0x6dc6eb, _0x870650);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(_0xf6f353[_0x678723] + _0xf6f353[_0x6dc6eb] == _0x737275);
    }

    function transfer(address _0x6dc6eb, uint256 _0x870650) public returns (bool _0x04743e) {
        _0xbd8074(msg.sender, _0x6dc6eb, _0x870650);
        return true;
    }

    function _0x9dfa36(address _0x678723, address _0x6dc6eb, uint256 _0x870650) public returns (bool _0x04743e) {
        require(_0x870650 <= _0xae75bb[_0x678723][msg.sender]);     // Check allowance
        _0xae75bb[_0x678723][msg.sender] -= _0x870650;
        _0xbd8074(_0x678723, _0x6dc6eb, _0x870650);
        return true;
    }

    function _0x1e9961(address _0xd535b2, uint256 _0x870650) public
        returns (bool _0x04743e) {
        _0xae75bb[msg.sender][_0xd535b2] = _0x870650;
        emit Approval(msg.sender, _0xd535b2, _0x870650);
        return true;
    }

    function _0xa8e4f4(address _0xd535b2, uint256 _0x870650, bytes _0xfdbcdc)
        public
        returns (bool _0x04743e) {
        _0x144455 _0x9d6487 = _0x144455(_0xd535b2);
        if (_0x1e9961(_0xd535b2, _0x870650)) {
            _0x9d6487._0x0da219(msg.sender, _0x870650, this, _0xfdbcdc);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedToken is _0xcab1f9, TokenERC20 {

    mapping (address => bool) public _0x405155;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address _0x8897e7, bool _0x0827e2);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedToken(
        string _0x092f76,
        string _0xa5dc5b
    ) TokenERC20(_0x092f76, _0xa5dc5b) public {}

    /* Internal transfer, only can be called by this contract */
    function _0xbd8074(address _0x678723, address _0x6dc6eb, uint _0x870650) internal {
        require (_0x6dc6eb != 0x0);                               // Prevent transfer to 0x0 address.
        require (_0xf6f353[_0x678723] >= _0x870650);               // Check if the sender has enough
        require (_0xf6f353[_0x6dc6eb] + _0x870650 >= _0xf6f353[_0x6dc6eb]);
        require(!_0x405155[_0x678723]);                     // Check if sender is frozen
        require(!_0x405155[_0x6dc6eb]);                       // Check if recipient is frozen
        _0xf6f353[_0x678723] -= _0x870650;                         // Subtract from the sender
        _0xf6f353[_0x6dc6eb] += _0x870650;                           // Add the same to the recipient
        emit Transfer(_0x678723, _0x6dc6eb, _0x870650);
    }

    /// @notice Buy tokens from contract by sending ether
    function _0x5125be() payable public {
        uint _0x6daa25 = msg.value;                          // calculates the amount
	_0xf6f353[msg.sender] += _0x6daa25;                  // updates the balance
        _0x17853b += _0x6daa25;                            // updates the total supply
        _0xbd8074(address(0x0), msg.sender, _0x6daa25);      // makes the transfer
    }

    /* Migration function */
    function _0x9e90ef() _0xb6d993 {
	assert(this.balance == _0x17853b);                 // consistency check
	suicide(_0xbca527);                                      // transfer the ether to the owner and kill the contract
    }
}