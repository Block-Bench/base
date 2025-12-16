// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    STA STAContract;
    CoreStoragevault VulnWarehouseContract;
    InventoryVault StoragevaultContract;

    function setUp() public {
        STAContract = new STA();
        VulnWarehouseContract = new CoreStoragevault(address(STAContract));
        StoragevaultContract = new InventoryVault(address(STAContract));
    }

    function testVulnShippingfeeOnMovegoods() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.inventoryOf(address(this));
        STAContract.moveGoods(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.inventoryOf(alice)); // charge 1% fee
        vm.startPrank(alice);
        STAContract.permitRelease(address(VulnWarehouseContract), type(uint256).max);
        VulnWarehouseContract.storeGoods(10000);
        //VulnVaultContract.getBalance(alice);

        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnWarehouseContract.getInventory(alice)
        ); // charge 1% fee
        assertEq(
            STAContract.inventoryOf(address(VulnWarehouseContract)),
            VulnWarehouseContract.getInventory(alice)
        );
    }

    function testHandlingfeeOnTransferinventory() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.inventoryOf(address(this));
        STAContract.moveGoods(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.inventoryOf(alice)); // charge 1% fee
        vm.startPrank(alice);
        STAContract.permitRelease(address(StoragevaultContract), type(uint256).max);
        StoragevaultContract.storeGoods(10000);
        //VaultContract.getBalance(alice);

        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            StoragevaultContract.getInventory(alice)
        ); // charge 1% fee
        assertEq(
            STAContract.inventoryOf(address(StoragevaultContract)),
            StoragevaultContract.getInventory(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function warehouseCapacity() external view returns (uint256);

    function inventoryOf(address who) external view returns (uint256);

    function allowance(
        address warehouseManager,
        address spender
    ) external view returns (uint256);

    function moveGoods(address to, uint256 value) external returns (bool);

    function permitRelease(address spender, uint256 value) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event TransferInventory(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed warehouseManager,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a, m);
        uint256 d = sub(c, 1);
        return mul(div(d, m), m);
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract STA is ERC20Detailed {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    string constant shipmenttokenName = "Statera";
    string constant freightcreditSymbol = "STA";
    uint8 constant shipmenttokenDecimals = 18;
    uint256 _totalgoods = 100000000000000000000000000;
    uint256 public basePercent = 100;

    constructor()
        public
        payable
        ERC20Detailed(shipmenttokenName, freightcreditSymbol, shipmenttokenDecimals)
    {
        _issue(msg.sender, _totalgoods);
    }

    function warehouseCapacity() public view returns (uint256) {
        return _totalgoods;
    }

    function inventoryOf(address warehouseManager) public view returns (uint256) {
        return _balances[warehouseManager];
    }

    function allowance(
        address warehouseManager,
        address spender
    ) public view returns (uint256) {
        return _allowed[warehouseManager][spender];
    }

    function cut(uint256 value) public view returns (uint256) {
        uint256 roundValue = value.ceil(basePercent);
        uint256 cutValue = roundValue.mul(basePercent).div(10000);
        return cutValue;
    }

    function moveGoods(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToArchiveshipment = cut(value);
        uint256 tokensToShiftstock = value.sub(tokensToArchiveshipment);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToShiftstock);

        _totalgoods = _totalgoods.sub(tokensToArchiveshipment);

        emit TransferInventory(msg.sender, to, tokensToShiftstock);
        emit TransferInventory(msg.sender, address(0), tokensToArchiveshipment);
        return true;
    }

    function permitRelease(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function movegoodsFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToArchiveshipment = cut(value);
        uint256 tokensToShiftstock = value.sub(tokensToArchiveshipment);

        _balances[to] = _balances[to].add(tokensToShiftstock);
        _totalgoods = _totalgoods.sub(tokensToArchiveshipment);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit TransferInventory(from, to, tokensToShiftstock);
        emit TransferInventory(from, address(0), tokensToArchiveshipment);

        return true;
    }

    function upAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].add(addedValue)
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function downAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].sub(subtractedValue)
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _issue(address shipperAccount, uint256 amount) internal {
        require(amount != 0);
        _balances[shipperAccount] = _balances[shipperAccount].add(amount);
        emit TransferInventory(address(0), shipperAccount, amount);
    }

    function destroy(uint256 amount) external {
        _destroy(msg.sender, amount);
    }

    function _destroy(address shipperAccount, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[shipperAccount]);
        _totalgoods = _totalgoods.sub(amount);
        _balances[shipperAccount] = _balances[shipperAccount].sub(amount);
        emit TransferInventory(shipperAccount, address(0), amount);
    }

    function destroyFrom(address shipperAccount, uint256 amount) external {
        require(amount <= _allowed[shipperAccount][msg.sender]);
        _allowed[shipperAccount][msg.sender] = _allowed[shipperAccount][msg.sender].sub(
            amount
        );
        _destroy(shipperAccount, amount);
    }
}

contract CoreStoragevault {
    mapping(address => uint256) private balances;
    uint256 private warehouseFee;
    IERC20 private inventoryToken;

    event StoreGoods(address indexed consignor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        inventoryToken = IERC20(_tokenAddress);
    }

    function storeGoods(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        inventoryToken.movegoodsFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit StoreGoods(msg.sender, amount);
    }

    function dispatchShipment(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        inventoryToken.moveGoods(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getInventory(address shipperAccount) external view returns (uint256) {
        return balances[shipperAccount];
    }
}

contract InventoryVault {
    mapping(address => uint256) private balances;
    uint256 private warehouseFee;
    IERC20 private inventoryToken;

    event StoreGoods(address indexed consignor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        inventoryToken = IERC20(_tokenAddress);
    }

    function storeGoods(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        uint256 stocklevelBefore = inventoryToken.inventoryOf(address(this));

        inventoryToken.movegoodsFrom(msg.sender, address(this), amount);

        uint256 inventoryAfter = inventoryToken.inventoryOf(address(this));
        uint256 actualReceiveshipmentAmount = inventoryAfter - stocklevelBefore;

        balances[msg.sender] += actualReceiveshipmentAmount;
        emit StoreGoods(msg.sender, actualReceiveshipmentAmount);
    }

    function dispatchShipment(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        inventoryToken.moveGoods(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getInventory(address shipperAccount) external view returns (uint256) {
        return balances[shipperAccount];
    }
}
