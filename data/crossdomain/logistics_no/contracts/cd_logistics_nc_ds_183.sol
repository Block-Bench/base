pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    STA STAContract;
    CoreInventoryvault VulnStoragevaultContract;
    StorageVault StoragevaultContract;

    function setUp() public {
        STAContract = new STA();
        VulnStoragevaultContract = new CoreInventoryvault(address(STAContract));
        StoragevaultContract = new StorageVault(address(STAContract));
    }

    function testVulnShippingfeeOnShiftstock() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.cargocountOf(address(this));
        STAContract.relocateCargo(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.cargocountOf(alice));
        vm.startPrank(alice);
        STAContract.approveDispatch(address(VulnStoragevaultContract), type(uint256).max);
        VulnStoragevaultContract.warehouseItems(10000);


        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnStoragevaultContract.getGoodsonhand(alice)
        );
        assertEq(
            STAContract.cargocountOf(address(VulnStoragevaultContract)),
            VulnStoragevaultContract.getGoodsonhand(alice)
        );
    }

    function testShippingfeeOnMovegoods() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.cargocountOf(address(this));
        STAContract.relocateCargo(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.cargocountOf(alice));
        vm.startPrank(alice);
        STAContract.approveDispatch(address(StoragevaultContract), type(uint256).max);
        StoragevaultContract.warehouseItems(10000);


        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            StoragevaultContract.getGoodsonhand(alice)
        );
        assertEq(
            STAContract.cargocountOf(address(StoragevaultContract)),
            StoragevaultContract.getGoodsonhand(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function warehouseCapacity() external view returns (uint256);

    function cargocountOf(address who) external view returns (uint256);

    function allowance(
        address logisticsAdmin,
        address spender
    ) external view returns (uint256);

    function relocateCargo(address to, uint256 value) external returns (bool);

    function approveDispatch(address spender, uint256 value) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event ShiftStock(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed logisticsAdmin,
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

    string constant cargotokenName = "Statera";
    string constant freightcreditSymbol = "STA";
    uint8 constant inventorytokenDecimals = 18;
    uint256 _totalgoods = 100000000000000000000000000;
    uint256 public basePercent = 100;

    constructor()
        public
        payable
        ERC20Detailed(cargotokenName, freightcreditSymbol, inventorytokenDecimals)
    {
        _issue(msg.sender, _totalgoods);
    }

    function warehouseCapacity() public view returns (uint256) {
        return _totalgoods;
    }

    function cargocountOf(address logisticsAdmin) public view returns (uint256) {
        return _balances[logisticsAdmin];
    }

    function allowance(
        address logisticsAdmin,
        address spender
    ) public view returns (uint256) {
        return _allowed[logisticsAdmin][spender];
    }

    function cut(uint256 value) public view returns (uint256) {
        uint256 roundValue = value.ceil(basePercent);
        uint256 cutValue = roundValue.mul(basePercent).div(10000);
        return cutValue;
    }

    function relocateCargo(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToRemovefrominventory = cut(value);
        uint256 tokensToShiftstock = value.sub(tokensToRemovefrominventory);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToShiftstock);

        _totalgoods = _totalgoods.sub(tokensToRemovefrominventory);

        emit ShiftStock(msg.sender, to, tokensToShiftstock);
        emit ShiftStock(msg.sender, address(0), tokensToRemovefrominventory);
        return true;
    }

    function approveDispatch(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function relocatecargoFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToRemovefrominventory = cut(value);
        uint256 tokensToShiftstock = value.sub(tokensToRemovefrominventory);

        _balances[to] = _balances[to].add(tokensToShiftstock);
        _totalgoods = _totalgoods.sub(tokensToRemovefrominventory);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit ShiftStock(from, to, tokensToShiftstock);
        emit ShiftStock(from, address(0), tokensToRemovefrominventory);

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

    function _issue(address logisticsAccount, uint256 amount) internal {
        require(amount != 0);
        _balances[logisticsAccount] = _balances[logisticsAccount].add(amount);
        emit ShiftStock(address(0), logisticsAccount, amount);
    }

    function destroy(uint256 amount) external {
        _destroy(msg.sender, amount);
    }

    function _destroy(address logisticsAccount, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[logisticsAccount]);
        _totalgoods = _totalgoods.sub(amount);
        _balances[logisticsAccount] = _balances[logisticsAccount].sub(amount);
        emit ShiftStock(logisticsAccount, address(0), amount);
    }

    function destroyFrom(address logisticsAccount, uint256 amount) external {
        require(amount <= _allowed[logisticsAccount][msg.sender]);
        _allowed[logisticsAccount][msg.sender] = _allowed[logisticsAccount][msg.sender].sub(
            amount
        );
        _destroy(logisticsAccount, amount);
    }
}

contract CoreInventoryvault {
    mapping(address => uint256) private balances;
    uint256 private processingCharge;
    IERC20 private inventoryToken;

    event ReceiveShipment(address indexed consignor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        inventoryToken = IERC20(_tokenAddress);
    }

    function warehouseItems(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        inventoryToken.relocatecargoFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit ReceiveShipment(msg.sender, amount);
    }

    function deliverGoods(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        inventoryToken.relocateCargo(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getGoodsonhand(address logisticsAccount) external view returns (uint256) {
        return balances[logisticsAccount];
    }
}

contract StorageVault {
    mapping(address => uint256) private balances;
    uint256 private processingCharge;
    IERC20 private inventoryToken;

    event ReceiveShipment(address indexed consignor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        inventoryToken = IERC20(_tokenAddress);
    }

    function warehouseItems(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        uint256 warehouselevelBefore = inventoryToken.cargocountOf(address(this));

        inventoryToken.relocatecargoFrom(msg.sender, address(this), amount);

        uint256 stocklevelAfter = inventoryToken.cargocountOf(address(this));
        uint256 actualReceiveshipmentAmount = stocklevelAfter - warehouselevelBefore;

        balances[msg.sender] += actualReceiveshipmentAmount;
        emit ReceiveShipment(msg.sender, actualReceiveshipmentAmount);
    }

    function deliverGoods(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        inventoryToken.relocateCargo(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getGoodsonhand(address logisticsAccount) external view returns (uint256) {
        return balances[logisticsAccount];
    }
}