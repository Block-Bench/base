pragma solidity 0.4.15;

contract ReputationToken {

    uint256 public allTips;


    function influenceOf(address _founder) constant returns (uint256 karma);


    function passInfluence(address _to, uint256 _value) returns (bool success);


    function givecreditFrom(address _from, address _to, uint256 _value) returns (bool success);


    function permitTransfer(address _spender, uint256 _value) returns (bool success);


    function allowance(address _founder, address _spender) constant returns (uint256 remaining);

    event GiveCredit(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _founder, address indexed _spender, uint256 _value);
}

contract StandardInfluencetoken is ReputationToken {

    function passInfluence(address _to, uint256 _value) returns (bool success) {


        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        GiveCredit(msg.sender, _to, _value);
        return true;
    }

    function givecreditFrom(address _from, address _to, uint256 _value) returns (bool success) {


        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        GiveCredit(_from, _to, _value);
        return true;
    }

    function influenceOf(address _founder) constant returns (uint256 karma) {
        return balances[_founder];
    }

    function permitTransfer(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _founder, address _spender) constant returns (uint256 remaining) {
      return allowed[_founder][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardInfluencetoken is StandardInfluencetoken {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H0.1';

    function HumanStandardInfluencetoken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;
        allTips = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }


    function allowtipAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}