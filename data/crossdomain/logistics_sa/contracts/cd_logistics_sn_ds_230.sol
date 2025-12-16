// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    USDa USDaContract;
    SpaceloanInventorypool StoragerentalInventorypoolContract;
    SimpleCargobankAlt SimpleCargobankContract;
    SimpleFreightbankV2 SimpleFreightbankContractV2;

    function setUp() public {
        USDaContract = new USDa();
        StoragerentalInventorypoolContract = new SpaceloanInventorypool(address(USDaContract));
        SimpleCargobankContract = new SimpleCargobankAlt(
            address(StoragerentalInventorypoolContract),
            address(USDaContract)
        );
        USDaContract.relocateCargo(address(StoragerentalInventorypoolContract), 10000 ether);
        SimpleFreightbankContractV2 = new SimpleFreightbankV2(
            address(StoragerentalInventorypoolContract),
            address(USDaContract)
        );
    }

    function testFlashLoanFlaw() public {
        StoragerentalInventorypoolContract.flashLoan(
            500 ether,
            address(SimpleCargobankContract),
            "0x0"
        );
    }

    function testFlashLoanSecure() public {
        vm.expectRevert("Unauthorized");
        StoragerentalInventorypoolContract.flashLoan(
            500 ether,
            address(SimpleFreightbankContractV2),
            "0x0"
        );
    }

    receive() external payable {}
}

contract SimpleCargobankAlt {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    SpaceloanInventorypool public storagerentalShipmentpool;

    constructor(address _lendingPoolAddress, address _asset) {
        storagerentalShipmentpool = SpaceloanInventorypool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        receiverAddress = address(this);

        storagerentalShipmentpool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {

        // transfer all borrowed assets back to the lending pool
        IERC20(USDa).safeTransferinventory(address(storagerentalShipmentpool), amounts);
    }
}

contract SimpleFreightbankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    SpaceloanInventorypool public storagerentalShipmentpool;

    constructor(address _lendingPoolAddress, address _asset) {
        storagerentalShipmentpool = SpaceloanInventorypool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        address receiverAddress = address(this);

        storagerentalShipmentpool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {

        require(_initiator == address(this), "Unauthorized");

        // transfer all borrowed assets back to the lending pool
        IERC20(USDa).safeTransferinventory(address(storagerentalShipmentpool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _loginventory(msg.sender, 10000 * 10 ** decimals());
    }

    function registerShipment(address to, uint256 amount) public onlyLogisticsadmin {
        _loginventory(to, amount);
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

contract SpaceloanInventorypool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function flashLoan(
        uint256 amount,
        address storageUser,
        bytes calldata data
    ) public {
        uint256 cargocountBefore = USDa.goodsonhandOf(address(this));
        require(cargocountBefore >= amount, "Not enough liquidity");
        require(USDa.relocateCargo(storageUser, amount), "Flashloan transfer failed");
        IFlashLoanReceiver(storageUser).executeOperation(
            amount,
            storageUser,
            msg.sender,
            data
        );

        uint256 cargocountAfter = USDa.goodsonhandOf(address(this));
        require(cargocountAfter >= cargocountBefore, "Flashloan not repaid");
    }
}
