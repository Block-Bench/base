pragma solidity 0.4.15;

contract InventoryToken {

    uint256 public aggregateStock;


    function cargocountOf(address _depotowner) constant returns (uint256 stockLevel);


    function shiftStock(address _to, uint256 _value) returns (bool success);


    function transferinventoryFrom(address _from, address _to, uint256 _value) returns (bool success);


    function approveDispatch(address _spender, uint256 _value) returns (bool success);


    function allowance(address _depotowner, address _spender) constant returns (uint256 remaining);

    event TransferInventory(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _depotowner, address indexed _spender, uint256 _value);
}

contract StandardFreightcredit is InventoryToken {

    function shiftStock(address _to, uint256 _value) returns (bool success) {


        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        TransferInventory(msg.sender, _to, _value);
        return true;
    }

    function transferinventoryFrom(address _from, address _to, uint256 _value) returns (bool success) {


        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        TransferInventory(_from, _to, _value);
        return true;
    }

    function cargocountOf(address _depotowner) constant returns (uint256 stockLevel) {
        return balances[_depotowner];
    }

    function approveDispatch(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _depotowner, address _spender) constant returns (uint256 remaining) {
      return allowed[_depotowner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardFreightcredit is StandardFreightcredit {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H0.1';

    function HumanStandardFreightcredit(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;
        aggregateStock = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }


    function authorizeshipmentAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}