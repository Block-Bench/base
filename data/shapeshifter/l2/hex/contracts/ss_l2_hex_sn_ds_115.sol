// https://etherscan.io/address/0x42d6622dece394b54999fbd73d108123806f6a18#code

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity 0.4.15;

contract Token {
    /// total amount of tokens
    uint256 public _0x0abe11;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x440ae2(address _0x94db44) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0x19f9a8, uint256 _0x1dfa75) returns (bool _0x5a9c9e);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function _0x80c9ae(address _0xe50e4f, address _0x19f9a8, uint256 _0x1dfa75) returns (bool _0x5a9c9e);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0xfdd737(address _0x055f54, uint256 _0x1dfa75) returns (bool _0x5a9c9e);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function _0x98ad41(address _0x94db44, address _0x055f54) constant returns (uint256 _0x71e80c);

    event Transfer(address indexed _0xe50e4f, address indexed _0x19f9a8, uint256 _0x1dfa75);
    event Approval(address indexed _0x94db44, address indexed _0x055f54, uint256 _0x1dfa75);
}

contract StandardToken is Token {

    function transfer(address _0x19f9a8, uint256 _0x1dfa75) returns (bool _0x5a9c9e) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0x978c83[msg.sender] >= _0x1dfa75);
        _0x978c83[msg.sender] -= _0x1dfa75;
        _0x978c83[_0x19f9a8] += _0x1dfa75;
        Transfer(msg.sender, _0x19f9a8, _0x1dfa75);
        return true;
    }

    function _0x80c9ae(address _0xe50e4f, address _0x19f9a8, uint256 _0x1dfa75) returns (bool _0x5a9c9e) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0x978c83[_0xe50e4f] >= _0x1dfa75 && _0x2bf3d7[_0xe50e4f][msg.sender] >= _0x1dfa75);
        _0x978c83[_0x19f9a8] += _0x1dfa75;
        _0x978c83[_0xe50e4f] -= _0x1dfa75;
        _0x2bf3d7[_0xe50e4f][msg.sender] -= _0x1dfa75;
        Transfer(_0xe50e4f, _0x19f9a8, _0x1dfa75);
        return true;
    }

    function _0x440ae2(address _0x94db44) constant returns (uint256 balance) {
        return _0x978c83[_0x94db44];
    }

    function _0xfdd737(address _0x055f54, uint256 _0x1dfa75) returns (bool _0x5a9c9e) {
        _0x2bf3d7[msg.sender][_0x055f54] = _0x1dfa75;
        Approval(msg.sender, _0x055f54, _0x1dfa75);
        return true;
    }

    function _0x98ad41(address _0x94db44, address _0x055f54) constant returns (uint256 _0x71e80c) {
      return _0x2bf3d7[_0x94db44][_0x055f54];
    }

    mapping (address => uint256) _0x978c83;
    mapping (address => mapping (address => uint256)) _0x2bf3d7;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */
    string public _0x79fe4c;                   //fancy name: eg Simon Bucks
    uint8 public _0x63c684;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public _0x6ccd11;                 //An identifier: eg SBX
    string public _0x631b44 = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 _0x31158c,
        string _0x3f44c6,
        uint8 _0x9e9998,
        string _0x79079b
        ) {
        _0x978c83[msg.sender] = _0x31158c;               // Give the creator all initial tokens
        _0x0abe11 = _0x31158c;                        // Update total supply
        _0x79fe4c = _0x3f44c6;                                   // Set the name for display purposes
        _0x63c684 = _0x9e9998;                            // Amount of decimals for display purposes
        _0x6ccd11 = _0x79079b;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function _0x5aa1c7(address _0x055f54, uint256 _0x1dfa75, bytes _0x541df0) returns (bool _0x5a9c9e) {
        _0x2bf3d7[msg.sender][_0x055f54] = _0x1dfa75;
        Approval(msg.sender, _0x055f54, _0x1dfa75);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_0x055f54.call(bytes4(bytes32(_0x5df070("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x1dfa75, this, _0x541df0));
        return true;
    }
}