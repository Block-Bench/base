// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    USDa USDaContract;
    BenefitadvanceCoveragepool MedicalloanCoveragepoolContract;
    SimpleBenefitbankAlt SimpleBenefitbankContract;
    SimpleMedicalbankV2 SimpleMedicalbankContractV2;

    function setUp() public {
        USDaContract = new USDa();
        MedicalloanCoveragepoolContract = new BenefitadvanceCoveragepool(address(USDaContract));
        SimpleBenefitbankContract = new SimpleBenefitbankAlt(
            address(MedicalloanCoveragepoolContract),
            address(USDaContract)
        );
        USDaContract.moveCoverage(address(MedicalloanCoveragepoolContract), 10000 ether);
        SimpleMedicalbankContractV2 = new SimpleMedicalbankV2(
            address(MedicalloanCoveragepoolContract),
            address(USDaContract)
        );
    }

    function testFlashLoanFlaw() public {
        MedicalloanCoveragepoolContract.flashLoan(
            500 ether,
            address(SimpleBenefitbankContract),
            "0x0"
        );
    }

    function testFlashLoanSecure() public {
        vm.expectRevert("Unauthorized");
        MedicalloanCoveragepoolContract.flashLoan(
            500 ether,
            address(SimpleMedicalbankContractV2),
            "0x0"
        );
    }

    receive() external payable {}
}

contract SimpleBenefitbankAlt {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    BenefitadvanceCoveragepool public medicalloanInsurancepool;

    constructor(address _lendingPoolAddress, address _asset) {
        medicalloanInsurancepool = BenefitadvanceCoveragepool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        receiverAddress = address(this);

        medicalloanInsurancepool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {

        // transfer all borrowed assets back to the lending pool
        IERC20(USDa).safeSharebenefit(address(medicalloanInsurancepool), amounts);
    }
}

contract SimpleMedicalbankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    BenefitadvanceCoveragepool public medicalloanInsurancepool;

    constructor(address _lendingPoolAddress, address _asset) {
        medicalloanInsurancepool = BenefitadvanceCoveragepool(_lendingPoolAddress);
        USDa = IERC20(_asset);
    }

    function flashLoan(
        uint256 amounts,
        address receiverAddress,
        bytes calldata data
    ) external {
        address receiverAddress = address(this);

        medicalloanInsurancepool.flashLoan(amounts, receiverAddress, data);
    }

    function executeOperation(
        uint256 amounts,
        address receiverAddress,
        address _initiator,
        bytes calldata data
    ) external {

        require(_initiator == address(this), "Unauthorized");

        // transfer all borrowed assets back to the lending pool
        IERC20(USDa).safeSharebenefit(address(medicalloanInsurancepool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _generatecredit(msg.sender, 10000 * 10 ** decimals());
    }

    function issueCoverage(address to, uint256 amount) public onlySupervisor {
        _generatecredit(to, amount);
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

contract BenefitadvanceCoveragepool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function flashLoan(
        uint256 amount,
        address advanceTaker,
        bytes calldata data
    ) public {
        uint256 creditsBefore = USDa.allowanceOf(address(this));
        require(creditsBefore >= amount, "Not enough liquidity");
        require(USDa.moveCoverage(advanceTaker, amount), "Flashloan transfer failed");
        IFlashLoanReceiver(advanceTaker).executeOperation(
            amount,
            advanceTaker,
            msg.sender,
            data
        );

        uint256 creditsAfter = USDa.allowanceOf(address(this));
        require(creditsAfter >= creditsBefore, "Flashloan not repaid");
    }
}
