// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract owned {
    address public warehouseManager;

    function owned() public {
        warehouseManager = msg.sender;
    }

    modifier onlyFacilityoperator {
        require(msg.sender == warehouseManager);
        _;
    }

    function transferinventoryOwnership(address newWarehousemanager) onlyFacilityoperator public {
        warehouseManager = newWarehousemanager;
    }
}

interface inventorytokenRecipient { function receiveApproval(address _from, uint256 _value, address _inventorytoken, bytes _extraData) external; }

contract FreightcreditErc20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalInventory;

    // This creates an array with all balances
    mapping (address => uint256) public goodsonhandOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event ShiftStock(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _warehousemanager, address indexed _spender, uint256 _value);

    function FreightcreditErc20(
        string shipmenttokenName,
        string freightcreditSymbol
    ) public {
        name = shipmenttokenName;                                   // Set the name for display purposes
        symbol = freightcreditSymbol;                               // Set the symbol for display purposes
    }

    function _shiftstock(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check if the sender has enough
        require(goodsonhandOf[_from] >= _value);

        require(goodsonhandOf[_to] + _value > goodsonhandOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = goodsonhandOf[_from] + goodsonhandOf[_to];
        // Subtract from the sender
        goodsonhandOf[_from] -= _value;
        // Add the same to the recipient
        goodsonhandOf[_to] += _value;
        emit ShiftStock(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(goodsonhandOf[_from] + goodsonhandOf[_to] == previousBalances);
    }

    function transferInventory(address _to, uint256 _value) public returns (bool success) {
        _shiftstock(msg.sender, _to, _value);
        return true;
    }

    function relocatecargoFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _shiftstock(_from, _to, _value);
        return true;
    }

    function authorizeShipment(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function clearcargoAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        inventorytokenRecipient spender = inventorytokenRecipient(_spender);
        if (authorizeShipment(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedShipmenttoken is owned, FreightcreditErc20 {

    mapping (address => bool) public frozenLogisticsaccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedShipmenttoken(
        string shipmenttokenName,
        string freightcreditSymbol
    ) FreightcreditErc20(shipmenttokenName, freightcreditSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _shiftstock(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address.
        require (goodsonhandOf[_from] >= _value);               // Check if the sender has enough
        require (goodsonhandOf[_to] + _value >= goodsonhandOf[_to]);
        require(!frozenLogisticsaccount[_from]);                     // Check if sender is frozen
        require(!frozenLogisticsaccount[_to]);                       // Check if recipient is frozen
        goodsonhandOf[_from] -= _value;                         // Subtract from the sender
        goodsonhandOf[_to] += _value;                           // Add the same to the recipient
        emit ShiftStock(_from, _to, _value);
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value;                          // calculates the amount
	goodsonhandOf[msg.sender] += amount;                  // updates the balance
        totalInventory += amount;                            // updates the total supply
        _shiftstock(address(0x0), msg.sender, amount);      // makes the transfer
    }

    /* Migration function */
    function migrate_and_destroy() onlyFacilityoperator {
	assert(this.stockLevel == totalInventory);                 // consistency check
	suicide(warehouseManager);                                      // transfer the ether to the owner and kill the contract
    }
}