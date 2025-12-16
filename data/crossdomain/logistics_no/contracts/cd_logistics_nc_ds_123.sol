pragma solidity ^0.4.16;

contract owned {
    address public depotOwner;

    function owned() public {
        depotOwner = msg.sender;
    }

    modifier onlyDepotowner {
        require(msg.sender == depotOwner);
        _;
    }

    function shiftstockOwnership(address newDepotowner) onlyDepotowner public {
        depotOwner = newDepotowner;
    }
}

interface cargotokenRecipient { function receiveApproval(address _from, uint256 _value, address _inventorytoken, bytes _extraData) external; }

contract FreightcreditErc20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public totalGoods;


    mapping (address => uint256) public goodsonhandOf;
    mapping (address => mapping (address => uint256)) public allowance;


    event TransferInventory(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed _warehousemanager, address indexed _spender, uint256 _value);

    function FreightcreditErc20(
        string inventorytokenName,
        string cargotokenSymbol
    ) public {
        name = inventorytokenName;
        symbol = cargotokenSymbol;
    }

    function _transferinventory(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(goodsonhandOf[_from] >= _value);

        require(goodsonhandOf[_to] + _value > goodsonhandOf[_to]);

        uint previousBalances = goodsonhandOf[_from] + goodsonhandOf[_to];

        goodsonhandOf[_from] -= _value;

        goodsonhandOf[_to] += _value;
        emit TransferInventory(_from, _to, _value);

        assert(goodsonhandOf[_from] + goodsonhandOf[_to] == previousBalances);
    }

    function moveGoods(address _to, uint256 _value) public returns (bool success) {
        _transferinventory(msg.sender, _to, _value);
        return true;
    }

    function relocatecargoFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transferinventory(_from, _to, _value);
        return true;
    }

    function clearCargo(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approvedispatchAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        cargotokenRecipient spender = cargotokenRecipient(_spender);
        if (clearCargo(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}


contract MyAdvancedCargotoken is owned, FreightcreditErc20 {

    mapping (address => bool) public frozenCargoprofile;


    event FrozenFunds(address target, bool frozen);


    function MyAdvancedCargotoken(
        string inventorytokenName,
        string cargotokenSymbol
    ) FreightcreditErc20(inventorytokenName, cargotokenSymbol) public {}


    function _transferinventory(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (goodsonhandOf[_from] >= _value);
        require (goodsonhandOf[_to] + _value >= goodsonhandOf[_to]);
        require(!frozenCargoprofile[_from]);
        require(!frozenCargoprofile[_to]);
        goodsonhandOf[_from] -= _value;
        goodsonhandOf[_to] += _value;
        emit TransferInventory(_from, _to, _value);
    }


    function buy() payable public {
        uint amount = msg.value;
	goodsonhandOf[msg.sender] += amount;
        totalGoods += amount;
        _transferinventory(address(0x0), msg.sender, amount);
    }


    function migrate_and_destroy() onlyDepotowner {
	assert(this.warehouseLevel == totalGoods);
	suicide(depotOwner);
    }
}