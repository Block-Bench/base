// https://etherscan.io/address/0x42d6622dece394b54999fbd73d108123806f6a18#code

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity 0.4.15;

contract Token {
    /// total amount of tokens
    uint256 public f;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function k(address t) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address y, uint256 s) returns (bool r);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function d(address v, address y, uint256 s) returns (bool r);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function p(address n, uint256 s) returns (bool r);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function i(address t, address n) constant returns (uint256 j);

    event Transfer(address indexed v, address indexed y, uint256 s);
    event Approval(address indexed t, address indexed n, uint256 s);
}

contract StandardToken is Token {

    function transfer(address y, uint256 s) returns (bool r) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(m[msg.sender] >= s);
        m[msg.sender] -= s;
        m[y] += s;
        Transfer(msg.sender, y, s);
        return true;
    }

    function d(address v, address y, uint256 s) returns (bool r) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(m[v] >= s && o[v][msg.sender] >= s);
        m[y] += s;
        m[v] -= s;
        o[v][msg.sender] -= s;
        Transfer(v, y, s);
        return true;
    }

    function k(address t) constant returns (uint256 balance) {
        return m[t];
    }

    function p(address n, uint256 s) returns (bool r) {
        o[msg.sender][n] = s;
        Approval(msg.sender, n, s);
        return true;
    }

    function i(address t, address n) constant returns (uint256 j) {
      return o[t][n];
    }

    mapping (address => uint256) m;
    mapping (address => mapping (address => uint256)) o;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */
    string public w;                   //fancy name: eg Simon Bucks
    uint8 public l;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public u;                 //An identifier: eg SBX
    string public q = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 a,
        string h,
        uint8 c,
        string e
        ) {
        m[msg.sender] = a;               // Give the creator all initial tokens
        f = a;                        // Update total supply
        w = h;                                   // Set the name for display purposes
        l = c;                            // Amount of decimals for display purposes
        u = e;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function b(address n, uint256 s, bytes g) returns (bool r) {
        o[msg.sender][n] = s;
        Approval(msg.sender, n, s);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(n.call(bytes4(bytes32(x("receiveApproval(address,uint256,address,bytes)"))), msg.sender, s, this, g));
        return true;
    }
}