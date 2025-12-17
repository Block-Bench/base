// https://etherscan.io/address/0x42d6622dece394b54999fbd73d108123806f6a18#code

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity 0.4.15;

contract Token {
    /// total amount of tokens
    uint256 public _0x7f5e98;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x59216e(address _0xbd9dc5) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0x418f06, uint256 _0xc8eae2) returns (bool _0x89c131);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function _0xd79d95(address _0x8b00db, address _0x418f06, uint256 _0xc8eae2) returns (bool _0x89c131);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0x55c7bb(address _0xf353d4, uint256 _0xc8eae2) returns (bool _0x89c131);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function _0x4509b8(address _0xbd9dc5, address _0xf353d4) constant returns (uint256 _0x8ebb48);

    event Transfer(address indexed _0x8b00db, address indexed _0x418f06, uint256 _0xc8eae2);
    event Approval(address indexed _0xbd9dc5, address indexed _0xf353d4, uint256 _0xc8eae2);
}

contract StandardToken is Token {

    function transfer(address _0x418f06, uint256 _0xc8eae2) returns (bool _0x89c131) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0x7bfedb[msg.sender] >= _0xc8eae2);
        _0x7bfedb[msg.sender] -= _0xc8eae2;
        _0x7bfedb[_0x418f06] += _0xc8eae2;
        Transfer(msg.sender, _0x418f06, _0xc8eae2);
        return true;
    }

    function _0xd79d95(address _0x8b00db, address _0x418f06, uint256 _0xc8eae2) returns (bool _0x89c131) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0x7bfedb[_0x8b00db] >= _0xc8eae2 && _0x18695f[_0x8b00db][msg.sender] >= _0xc8eae2);
        _0x7bfedb[_0x418f06] += _0xc8eae2;
        _0x7bfedb[_0x8b00db] -= _0xc8eae2;
        _0x18695f[_0x8b00db][msg.sender] -= _0xc8eae2;
        Transfer(_0x8b00db, _0x418f06, _0xc8eae2);
        return true;
    }

    function _0x59216e(address _0xbd9dc5) constant returns (uint256 balance) {
        return _0x7bfedb[_0xbd9dc5];
    }

    function _0x55c7bb(address _0xf353d4, uint256 _0xc8eae2) returns (bool _0x89c131) {
        _0x18695f[msg.sender][_0xf353d4] = _0xc8eae2;
        Approval(msg.sender, _0xf353d4, _0xc8eae2);
        return true;
    }

    function _0x4509b8(address _0xbd9dc5, address _0xf353d4) constant returns (uint256 _0x8ebb48) {
      return _0x18695f[_0xbd9dc5][_0xf353d4];
    }

    mapping (address => uint256) _0x7bfedb;
    mapping (address => mapping (address => uint256)) _0x18695f;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */
    string public _0x850470;                   //fancy name: eg Simon Bucks
    uint8 public _0x28d29b;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public _0xd8be24;                 //An identifier: eg SBX
    string public _0xa87d58 = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 _0x1d1788,
        string _0xe286c7,
        uint8 _0x5c39d2,
        string _0x02dd87
        ) {
        _0x7bfedb[msg.sender] = _0x1d1788;               // Give the creator all initial tokens
        _0x7f5e98 = _0x1d1788;                        // Update total supply
        _0x850470 = _0xe286c7;                                   // Set the name for display purposes
        _0x28d29b = _0x5c39d2;                            // Amount of decimals for display purposes
        _0xd8be24 = _0x02dd87;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function _0x8dc8fa(address _0xf353d4, uint256 _0xc8eae2, bytes _0xf6d223) returns (bool _0x89c131) {
        _0x18695f[msg.sender][_0xf353d4] = _0xc8eae2;
        Approval(msg.sender, _0xf353d4, _0xc8eae2);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_0xf353d4.call(bytes4(bytes32(_0x4b70fd("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0xc8eae2, this, _0xf6d223));
        return true;
    }
}