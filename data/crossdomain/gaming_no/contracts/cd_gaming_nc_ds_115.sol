pragma solidity 0.4.15;

contract GoldToken {

    uint256 public worldSupply;


    function treasurecountOf(address _realmlord) constant returns (uint256 goldHolding);


    function shareTreasure(address _to, uint256 _value) returns (bool success);


    function tradelootFrom(address _from, address _to, uint256 _value) returns (bool success);


    function allowTransfer(address _spender, uint256 _value) returns (bool success);


    function allowance(address _realmlord, address _spender) constant returns (uint256 remaining);

    event TradeLoot(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _realmlord, address indexed _spender, uint256 _value);
}

contract StandardRealmcoin is GoldToken {

    function shareTreasure(address _to, uint256 _value) returns (bool success) {


        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        TradeLoot(msg.sender, _to, _value);
        return true;
    }

    function tradelootFrom(address _from, address _to, uint256 _value) returns (bool success) {


        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        TradeLoot(_from, _to, _value);
        return true;
    }

    function treasurecountOf(address _realmlord) constant returns (uint256 goldHolding) {
        return balances[_realmlord];
    }

    function allowTransfer(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _realmlord, address _spender) constant returns (uint256 remaining) {
      return allowed[_realmlord][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardRealmcoin is StandardRealmcoin {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H0.1';

    function HumanStandardRealmcoin(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;
        worldSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }


    function permittradeAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}