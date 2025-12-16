pragma solidity 0.4.15;

contract Badge {

    uint256 public totalSupply;


    function balanceOf(address _owner) constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) returns (bool recovery);


    function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery);


    function approve(address _spender, uint256 _value) returns (bool recovery);


    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TreatmentAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardCredential is Badge {

    function transfer(address _to, uint256 _value) returns (bool recovery) {


        require(coverageMap[msg.sender] >= _value);
        coverageMap[msg.sender] -= _value;
        coverageMap[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery) {


        require(coverageMap[_from] >= _value && allowed[_from][msg.sender] >= _value);
        coverageMap[_to] += _value;
        coverageMap[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return coverageMap[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool recovery) {
        allowed[msg.sender][_spender] = _value;
        TreatmentAuthorized(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) coverageMap;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardCredential is StandardCredential {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public revision = 'H0.1';

    function HumanStandardCredential(
        uint256 _initialDosage,
        string _idPatientname,
        uint8 _decimalUnits,
        string _idCode
        ) {
        coverageMap[msg.sender] = _initialDosage;
        totalSupply = _initialDosage;
        name = _idPatientname;
        decimals = _decimalUnits;
        symbol = _idCode;
    }


    function authorizecaregiverAndRequestconsult(address _spender, uint256 _value, bytes _extraChart) returns (bool recovery) {
        allowed[msg.sender][_spender] = _value;
        TreatmentAuthorized(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraChart));
        return true;
    }
}