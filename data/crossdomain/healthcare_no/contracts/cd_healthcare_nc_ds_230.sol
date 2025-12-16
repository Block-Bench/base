pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    USDa USDaContract;
    MedicalloanInsurancepool HealthcreditBenefitpoolContract;
    SimpleMedicalbankAlt SimpleHealthbankContract;
    SimpleMedicalbankV2 SimpleHealthbankContractV2;

    function setUp() public {
        USDaContract = new USDa();
        HealthcreditBenefitpoolContract = new MedicalloanInsurancepool(address(USDaContract));
        SimpleHealthbankContract = new SimpleMedicalbankAlt(
            address(HealthcreditBenefitpoolContract),
            address(USDaContract)
        );
        USDaContract.assignCredit(address(HealthcreditBenefitpoolContract), 10000 ether);
        SimpleHealthbankContractV2 = new SimpleMedicalbankV2(
            address(HealthcreditBenefitpoolContract),
            address(USDaContract)
        );
    }

    function testFlashLoanFlaw() public {
        HealthcreditBenefitpoolContract.flashLoan(
            500 ether,
            address(SimpleHealthbankContract),
            "0x0"
        );
    }

    function testFlashLoanSecure() public {
        vm.expectRevert("Unauthorized");
        HealthcreditBenefitpoolContract.flashLoan(
            500 ether,
            address(SimpleHealthbankContractV2),
            "0x0"
        );
    }

    receive() external payable {}
}

contract SimpleMedicalbankAlt {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    MedicalloanInsurancepool public medicalloanClaimpool;

    constructor(address _lendingPoolAddress, address _asset) {
        medicalloanClaimpool = MedicalloanInsurancepool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        receiverAddress = address(this);

        medicalloanClaimpool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {


        IERC20(USDa).safeAssigncredit(address(medicalloanClaimpool), amounts);
    }
}

contract SimpleMedicalbankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    MedicalloanInsurancepool public medicalloanClaimpool;

    constructor(address _lendingPoolAddress, address _asset) {
        medicalloanClaimpool = MedicalloanInsurancepool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        address receiverAddress = address(this);

        medicalloanClaimpool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {

        require(_initiator == address(this), "Unauthorized");


        IERC20(USDa).safeAssigncredit(address(medicalloanClaimpool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _assigncoverage(msg.sender, 10000 * 10 ** decimals());
    }

    function assignCoverage(address to, uint256 amount) public onlyAdministrator {
        _assigncoverage(to, amount);
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

contract MedicalloanInsurancepool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function flashLoan(
        uint256 amount,
        address advanceTaker,
        bytes calldata data
    ) public {
        uint256 coverageBefore = USDa.remainingbenefitOf(address(this));
        require(coverageBefore >= amount, "Not enough liquidity");
        require(USDa.assignCredit(advanceTaker, amount), "Flashloan transfer failed");
        IFlashLoanReceiver(advanceTaker).executeOperation(
            amount,
            advanceTaker,
            msg.sender,
            data
        );

        uint256 remainingbenefitAfter = USDa.remainingbenefitOf(address(this));
        require(remainingbenefitAfter >= coverageBefore, "Flashloan not repaid");
    }
}