pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    USDa USDaContract;
    StoragerentalShipmentpool CapacityleaseCargopoolContract;
    SimpleFreightbankAlt SimpleInventorybankContract;
    SimpleFreightbankV2 SimpleInventorybankContractV2;

    function setUp() public {
        USDaContract = new USDa();
        CapacityleaseCargopoolContract = new StoragerentalShipmentpool(address(USDaContract));
        SimpleInventorybankContract = new SimpleFreightbankAlt(
            address(CapacityleaseCargopoolContract),
            address(USDaContract)
        );
        USDaContract.shiftStock(address(CapacityleaseCargopoolContract), 10000 ether);
        SimpleInventorybankContractV2 = new SimpleFreightbankV2(
            address(CapacityleaseCargopoolContract),
            address(USDaContract)
        );
    }

    function testFlashLoanFlaw() public {
        CapacityleaseCargopoolContract.flashLoan(
            500 ether,
            address(SimpleInventorybankContract),
            "0x0"
        );
    }

    function testFlashLoanSecure() public {
        vm.expectRevert("Unauthorized");
        CapacityleaseCargopoolContract.flashLoan(
            500 ether,
            address(SimpleInventorybankContractV2),
            "0x0"
        );
    }

    receive() external payable {}
}

contract SimpleFreightbankAlt {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    StoragerentalShipmentpool public storagerentalFreightpool;

    constructor(address _lendingPoolAddress, address _asset) {
        storagerentalFreightpool = StoragerentalShipmentpool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        receiverAddress = address(this);

        storagerentalFreightpool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {


        IERC20(USDa).safeShiftstock(address(storagerentalFreightpool), amounts);
    }
}

contract SimpleFreightbankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    StoragerentalShipmentpool public storagerentalFreightpool;

    constructor(address _lendingPoolAddress, address _asset) {
        storagerentalFreightpool = StoragerentalShipmentpool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        address receiverAddress = address(this);

        storagerentalFreightpool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {

        require(_initiator == address(this), "Unauthorized");


        IERC20(USDa).safeShiftstock(address(storagerentalFreightpool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _recordcargo(msg.sender, 10000 * 10 ** decimals());
    }

    function recordCargo(address to, uint256 amount) public onlyWarehousemanager {
        _recordcargo(to, amount);
    }
}

interface IFlashLoanReceiver {
    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external;
}

contract StoragerentalShipmentpool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function flashLoan(
        uint256 amount,
        address storageUser,
        bytes calldata data
    ) public {
        uint256 inventoryBefore = USDa.warehouselevelOf(address(this));
        require(inventoryBefore >= amount, "Not enough liquidity");
        require(USDa.shiftStock(storageUser, amount), "Flashloan transfer failed");
        IFlashLoanReceiver(storageUser).executeOperation(
            amount,
            storageUser,
            msg.sender,
            data
        );

        uint256 warehouselevelAfter = USDa.warehouselevelOf(address(this));
        require(warehouselevelAfter >= inventoryBefore, "Flashloan not repaid");
    }
}