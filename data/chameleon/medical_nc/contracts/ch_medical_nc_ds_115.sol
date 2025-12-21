pragma solidity 0.4.15;

contract Credential {

    uint256 public totalSupply;


    function balanceOf(address _owner) constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) returns (bool recovery);


    function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery);


    function approve(address _spender, uint256 _value) returns (bool recovery);


    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardCredential is Credential {

    function transfer(address _to, uint256 _value) returns (bool recovery) {


        require(accountCreditsMap[msg.sender] >= _value);
        accountCreditsMap[msg.sender] -= _value;
        accountCreditsMap[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery) {


        require(accountCreditsMap[_from] >= _value && authorized[_from][msg.sender] >= _value);
        accountCreditsMap[_to] += _value;
        accountCreditsMap[_from] -= _value;
        authorized[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return accountCreditsMap[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool recovery) {
        authorized[msg.sender][_spender] = _value;
        AccessAuthorized(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return authorized[_owner][_spender];
    }

    mapping (address => uint256) accountCreditsMap;
    mapping (address => mapping (address => uint256)) authorized;
}

contract HumanStandardCredential is StandardCredential {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public edition = 'H0.1';

    function HumanStandardCredential(
        uint256 _initialQuantity,
        string _credentialPatientname,
        uint8 _decimalUnits,
        string _credentialCode
        ) {
        accountCreditsMap[msg.sender] = _initialQuantity;
        totalSupply = _initialQuantity;
        name = _credentialPatientname;
        decimals = _decimalUnits;
        symbol = _credentialCode;
    }


    function authorizeaccessAndConsultspecialist(address _spender, uint256 _value, bytes _extraChart) returns (bool recovery) {
        authorized[msg.sender][_spender] = _value;
        AccessAuthorized(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraChart));
        return true;
    }
}