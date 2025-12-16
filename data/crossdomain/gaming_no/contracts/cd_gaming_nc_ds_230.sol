pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    USDa USDaContract;
    ItemloanRewardpool GoldlendingPrizepoolContract;
    SimpleQuestbankAlt SimpleGoldbankContract;
    SimpleQuestbankV2 SimpleGoldbankContractV2;

    function setUp() public {
        USDaContract = new USDa();
        GoldlendingPrizepoolContract = new ItemloanRewardpool(address(USDaContract));
        SimpleGoldbankContract = new SimpleQuestbankAlt(
            address(GoldlendingPrizepoolContract),
            address(USDaContract)
        );
        USDaContract.shareTreasure(address(GoldlendingPrizepoolContract), 10000 ether);
        SimpleGoldbankContractV2 = new SimpleQuestbankV2(
            address(GoldlendingPrizepoolContract),
            address(USDaContract)
        );
    }

    function testFlashLoanFlaw() public {
        GoldlendingPrizepoolContract.flashLoan(
            500 ether,
            address(SimpleGoldbankContract),
            "0x0"
        );
    }

    function testFlashLoanSecure() public {
        vm.expectRevert("Unauthorized");
        GoldlendingPrizepoolContract.flashLoan(
            500 ether,
            address(SimpleGoldbankContractV2),
            "0x0"
        );
    }

    receive() external payable {}
}

contract SimpleQuestbankAlt {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    ItemloanRewardpool public itemloanBountypool;

    constructor(address _lendingPoolAddress, address _asset) {
        itemloanBountypool = ItemloanRewardpool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        receiverAddress = address(this);

        itemloanBountypool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {


        IERC20(USDa).safeSharetreasure(address(itemloanBountypool), amounts);
    }
}

contract SimpleQuestbankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    ItemloanRewardpool public itemloanBountypool;

    constructor(address _lendingPoolAddress, address _asset) {
        itemloanBountypool = ItemloanRewardpool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        address receiverAddress = address(this);

        itemloanBountypool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {

        require(_initiator == address(this), "Unauthorized");


        IERC20(USDa).safeSharetreasure(address(itemloanBountypool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _generateloot(msg.sender, 10000 * 10 ** decimals());
    }

    function generateLoot(address to, uint256 amount) public onlyGamemaster {
        _generateloot(to, amount);
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

contract ItemloanRewardpool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function flashLoan(
        uint256 amount,
        address loanTaker,
        bytes calldata data
    ) public {
        uint256 lootbalanceBefore = USDa.itemcountOf(address(this));
        require(lootbalanceBefore >= amount, "Not enough liquidity");
        require(USDa.shareTreasure(loanTaker, amount), "Flashloan transfer failed");
        IFlashLoanReceiver(loanTaker).executeOperation(
            amount,
            loanTaker,
            msg.sender,
            data
        );

        uint256 itemcountAfter = USDa.itemcountOf(address(this));
        require(itemcountAfter >= lootbalanceBefore, "Flashloan not repaid");
    }
}