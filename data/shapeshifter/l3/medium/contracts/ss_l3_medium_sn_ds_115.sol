// https://etherscan.io/address/0x42d6622dece394b54999fbd73d108123806f6a18#code

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity 0.4.15;

contract Token {
    /// total amount of tokens
    uint256 public _0xe4fb4a;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x5b758c(address _0xe2d45d) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0x4d93af, uint256 _0xc3319e) returns (bool _0x5caa7b);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function _0x391400(address _0xbc7a67, address _0x4d93af, uint256 _0xc3319e) returns (bool _0x5caa7b);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0x16b993(address _0xae352d, uint256 _0xc3319e) returns (bool _0x5caa7b);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function _0x488dc5(address _0xe2d45d, address _0xae352d) constant returns (uint256 _0xb9e6e2);

    event Transfer(address indexed _0xbc7a67, address indexed _0x4d93af, uint256 _0xc3319e);
    event Approval(address indexed _0xe2d45d, address indexed _0xae352d, uint256 _0xc3319e);
}

contract StandardToken is Token {

    function transfer(address _0x4d93af, uint256 _0xc3319e) returns (bool _0x5caa7b) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0xbc25f8[msg.sender] >= _0xc3319e);
        _0xbc25f8[msg.sender] -= _0xc3319e;
        _0xbc25f8[_0x4d93af] += _0xc3319e;
        Transfer(msg.sender, _0x4d93af, _0xc3319e);
        return true;
    }

    function _0x391400(address _0xbc7a67, address _0x4d93af, uint256 _0xc3319e) returns (bool _0x5caa7b) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0xbc25f8[_0xbc7a67] >= _0xc3319e && _0x2b3e97[_0xbc7a67][msg.sender] >= _0xc3319e);
        _0xbc25f8[_0x4d93af] += _0xc3319e;
        _0xbc25f8[_0xbc7a67] -= _0xc3319e;
        _0x2b3e97[_0xbc7a67][msg.sender] -= _0xc3319e;
        Transfer(_0xbc7a67, _0x4d93af, _0xc3319e);
        return true;
    }

    function _0x5b758c(address _0xe2d45d) constant returns (uint256 balance) {
        return _0xbc25f8[_0xe2d45d];
    }

    function _0x16b993(address _0xae352d, uint256 _0xc3319e) returns (bool _0x5caa7b) {
        _0x2b3e97[msg.sender][_0xae352d] = _0xc3319e;
        Approval(msg.sender, _0xae352d, _0xc3319e);
        return true;
    }

    function _0x488dc5(address _0xe2d45d, address _0xae352d) constant returns (uint256 _0xb9e6e2) {
      return _0x2b3e97[_0xe2d45d][_0xae352d];
    }

    mapping (address => uint256) _0xbc25f8;
    mapping (address => mapping (address => uint256)) _0x2b3e97;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */
    string public _0x453f38;                   //fancy name: eg Simon Bucks
    uint8 public _0xfa35ac;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public _0x1b7a38;                 //An identifier: eg SBX
    string public _0x8f90d1 = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 _0x915a75,
        string _0x888aa8,
        uint8 _0xe413af,
        string _0xccc6f8
        ) {
        _0xbc25f8[msg.sender] = _0x915a75;               // Give the creator all initial tokens
        _0xe4fb4a = _0x915a75;                        // Update total supply
        _0x453f38 = _0x888aa8;                                   // Set the name for display purposes
        _0xfa35ac = _0xe413af;                            // Amount of decimals for display purposes
        _0x1b7a38 = _0xccc6f8;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function _0x2cdd14(address _0xae352d, uint256 _0xc3319e, bytes _0xc3b517) returns (bool _0x5caa7b) {
        _0x2b3e97[msg.sender][_0xae352d] = _0xc3319e;
        Approval(msg.sender, _0xae352d, _0xc3319e);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_0xae352d.call(bytes4(bytes32(_0x42245a("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0xc3319e, this, _0xc3b517));
        return true;
    }
}