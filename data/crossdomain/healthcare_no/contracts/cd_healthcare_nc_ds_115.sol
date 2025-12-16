pragma solidity 0.4.15;

contract CoverageToken {

    uint256 public fundTotal;


    function creditsOf(address _coordinator) constant returns (uint256 benefits);


    function assignCredit(address _to, uint256 _value) returns (bool success);


    function sharebenefitFrom(address _from, address _to, uint256 _value) returns (bool success);


    function validateClaim(address _spender, uint256 _value) returns (bool success);


    function allowance(address _coordinator, address _spender) constant returns (uint256 remaining);

    event ShareBenefit(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _coordinator, address indexed _spender, uint256 _value);
}

contract StandardMedicalcredit is CoverageToken {

    function assignCredit(address _to, uint256 _value) returns (bool success) {


        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        ShareBenefit(msg.sender, _to, _value);
        return true;
    }

    function sharebenefitFrom(address _from, address _to, uint256 _value) returns (bool success) {


        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        ShareBenefit(_from, _to, _value);
        return true;
    }

    function creditsOf(address _coordinator) constant returns (uint256 benefits) {
        return balances[_coordinator];
    }

    function validateClaim(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _coordinator, address _spender) constant returns (uint256 remaining) {
      return allowed[_coordinator][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardMedicalcredit is StandardMedicalcredit {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H0.1';

    function HumanStandardMedicalcredit(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;
        fundTotal = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }


    function authorizeclaimAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}