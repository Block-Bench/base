pragma solidity 0.4.15;

contract Medal {

    uint256 public totalSupply;


    function balanceOf(address _owner) constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) returns (bool win);


    function transferFrom(address _from, address _to, uint256 _value) returns (bool win);


    function approve(address _spender, uint256 _value) returns (bool win);


    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardGem is Medal {

    function transfer(address _to, uint256 _value) returns (bool win) {


        require(characterGold[msg.sender] >= _value);
        characterGold[msg.sender] -= _value;
        characterGold[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool win) {


        require(characterGold[_from] >= _value && allowed[_from][msg.sender] >= _value);
        characterGold[_to] += _value;
        characterGold[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return characterGold[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool win) {
        allowed[msg.sender][_spender] = _value;
        AccessAuthorized(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) characterGold;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardGem is StandardGem {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public edition = 'H0.1';

    function HumanStandardGem(
        uint256 _initialTotal,
        string _medalTitle,
        uint8 _decimalUnits,
        string _gemIcon
        ) {
        characterGold[msg.sender] = _initialTotal;
        totalSupply = _initialTotal;
        name = _medalTitle;
        decimals = _decimalUnits;
        symbol = _gemIcon;
    }


    function grantpermissionAndInvokespell(address _spender, uint256 _value, bytes _extraDetails) returns (bool win) {
        allowed[msg.sender][_spender] = _value;
        AccessAuthorized(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraDetails));
        return true;
    }
}