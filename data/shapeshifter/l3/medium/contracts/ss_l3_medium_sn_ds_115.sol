// https://etherscan.io/address/0x42d6622dece394b54999fbd73d108123806f6a18#code

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity 0.4.15;

contract Token {
    /// total amount of tokens
    uint256 public _0x036c95;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x87d781(address _0x661bb8) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0xd0b2e0, uint256 _0xe0eeae) returns (bool _0x35e126);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function _0x6cb774(address _0x498af0, address _0xd0b2e0, uint256 _0xe0eeae) returns (bool _0x35e126);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0xf85432(address _0x1c9131, uint256 _0xe0eeae) returns (bool _0x35e126);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function _0x13c50c(address _0x661bb8, address _0x1c9131) constant returns (uint256 _0xf847fa);

    event Transfer(address indexed _0x498af0, address indexed _0xd0b2e0, uint256 _0xe0eeae);
    event Approval(address indexed _0x661bb8, address indexed _0x1c9131, uint256 _0xe0eeae);
}

contract StandardToken is Token {

    function transfer(address _0xd0b2e0, uint256 _0xe0eeae) returns (bool _0x35e126) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0xd633b6[msg.sender] >= _0xe0eeae);
        _0xd633b6[msg.sender] -= _0xe0eeae;
        _0xd633b6[_0xd0b2e0] += _0xe0eeae;
        Transfer(msg.sender, _0xd0b2e0, _0xe0eeae);
        return true;
    }

    function _0x6cb774(address _0x498af0, address _0xd0b2e0, uint256 _0xe0eeae) returns (bool _0x35e126) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0xd633b6[_0x498af0] >= _0xe0eeae && _0x07c1a1[_0x498af0][msg.sender] >= _0xe0eeae);
        _0xd633b6[_0xd0b2e0] += _0xe0eeae;
        _0xd633b6[_0x498af0] -= _0xe0eeae;
        _0x07c1a1[_0x498af0][msg.sender] -= _0xe0eeae;
        Transfer(_0x498af0, _0xd0b2e0, _0xe0eeae);
        return true;
    }

    function _0x87d781(address _0x661bb8) constant returns (uint256 balance) {
        return _0xd633b6[_0x661bb8];
    }

    function _0xf85432(address _0x1c9131, uint256 _0xe0eeae) returns (bool _0x35e126) {
        _0x07c1a1[msg.sender][_0x1c9131] = _0xe0eeae;
        Approval(msg.sender, _0x1c9131, _0xe0eeae);
        return true;
    }

    function _0x13c50c(address _0x661bb8, address _0x1c9131) constant returns (uint256 _0xf847fa) {
      return _0x07c1a1[_0x661bb8][_0x1c9131];
    }

    mapping (address => uint256) _0xd633b6;
    mapping (address => mapping (address => uint256)) _0x07c1a1;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */
    string public _0x421c3f;                   //fancy name: eg Simon Bucks
    uint8 public _0x1f2a79;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public _0x8240d2;                 //An identifier: eg SBX
    string public _0x931b0b = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 _0x768fc2,
        string _0xb3b879,
        uint8 _0x33347c,
        string _0x4aba79
        ) {
        _0xd633b6[msg.sender] = _0x768fc2;               // Give the creator all initial tokens
        _0x036c95 = _0x768fc2;                        // Update total supply
        _0x421c3f = _0xb3b879;                                   // Set the name for display purposes
        _0x1f2a79 = _0x33347c;                            // Amount of decimals for display purposes
        _0x8240d2 = _0x4aba79;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function _0x7f1913(address _0x1c9131, uint256 _0xe0eeae, bytes _0x7841d3) returns (bool _0x35e126) {
        _0x07c1a1[msg.sender][_0x1c9131] = _0xe0eeae;
        Approval(msg.sender, _0x1c9131, _0xe0eeae);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_0x1c9131.call(bytes4(bytes32(_0x595ad1("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0xe0eeae, this, _0x7841d3));
        return true;
    }
}