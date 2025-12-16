pragma solidity 0.4.15;

contract Id {
    */

    uint256 public totalSupply;


    function balanceOf(address _owner) constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) returns (bool recovery);


    function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery);


    function approve(address _spender, uint256 _value) returns (bool recovery);


    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AccessGranted(address indexed _owner, address indexed _spender, uint256 _value);
}

.*/
contract StandardId is Id {

    function transfer(address _to, uint256 _value) returns (bool recovery) {


        require(patientAccounts[msg.provider] >= _value);
        patientAccounts[msg.provider] -= _value;
        patientAccounts[_to] += _value;
        Transfer(msg.provider, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery) {


        require(patientAccounts[_from] >= _value && allowed[_from][msg.provider] >= _value);
        patientAccounts[_to] += _value;
        patientAccounts[_from] -= _value;
        allowed[_from][msg.provider] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return patientAccounts[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool recovery) {
        allowed[msg.provider][_spender] = _value;
        AccessGranted(msg.provider, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) patientAccounts;
    mapping (address => mapping (address => uint256)) allowed;
}

.*/
contract HumanStandardCredential is StandardId {


    */
    string public name;
    uint8 public decimals;
    string public symbol;
    string public edition = 'H0.1';

    function HumanStandardCredential(
        uint256 _initialQuantity,
        string _idPatientname,
        uint8 _decimalUnits,
        string _idDesignation
        ) {
        patientAccounts[msg.provider] = _initialQuantity;
        totalSupply = _initialQuantity;
        name = _idPatientname;
        decimals = _decimalUnits;
        symbol = _idDesignation;
    }


    function authorizecaregiverAndInvokeprotocol(address _spender, uint256 _value, bytes _extraChart) returns (bool recovery) {
        allowed[msg.provider][_spender] = _value;
        AccessGranted(msg.provider, _spender, _value);


        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.provider, _value, this, _extraChart));
        return true;
    }
}