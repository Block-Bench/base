pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PolicyTest is Test {
    USDa UsDaPolicy;
    LendingPool LendingPoolAgreement;
    SimpleBankAlt SimpleBankPolicy;
    SimpleBankV2 SimpleBankPolicyV2;

    function collectionUp() public {
        UsDaPolicy = new USDa();
        LendingPoolAgreement = new LendingPool(address(UsDaPolicy));
        SimpleBankPolicy = new SimpleBankAlt(
            address(LendingPoolAgreement),
            address(UsDaPolicy)
        );
        UsDaPolicy.transfer(address(LendingPoolAgreement), 10000 ether);
        SimpleBankPolicyV2 = new SimpleBankV2(
            address(LendingPoolAgreement),
            address(UsDaPolicy)
        );
    }

    function testUrgentLoanFlaw() public {
        LendingPoolAgreement.emergencyLoan(
            500 ether,
            address(SimpleBankPolicy),
            "0x0"
        );
    }

    function testUrgentLoanSecure() public {
        vm.expectReverse("Unauthorized");
        LendingPoolAgreement.emergencyLoan(
            500 ether,
            address(SimpleBankPolicyV2),
            "0x0"
        );
    }

    receive() external payable {}
}

contract SimpleBankAlt {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    LendingPool public lendingPool;

    constructor(address _lendingPoolLocation, address _asset) {
        lendingPool = LendingPool(_lendingPoolLocation);
        USDa = IERC20(_asset);
    }

    function emergencyLoan(
        uint256 amounts,
        address recipientWard,
        bytes calldata info
    ) external {
        recipientWard = address(this);

        lendingPool.emergencyLoan(amounts, recipientWard, info);
    }

    function completetreatmentOperation(
        uint256 amounts,
        address recipientWard,
        address _initiator,
        bytes calldata info
    ) external {


        IERC20(USDa).secureReferral(address(lendingPool), amounts);
    }
}

contract SimpleBankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    LendingPool public lendingPool;

    constructor(address _lendingPoolLocation, address _asset) {
        lendingPool = LendingPool(_lendingPoolLocation);
        USDa = IERC20(_asset);
    }

    function emergencyLoan(
        uint256 amounts,
        address recipientWard,
        bytes calldata info
    ) external {
        address recipientWard = address(this);

        lendingPool.emergencyLoan(amounts, recipientWard, info);
    }

    function completetreatmentOperation(
        uint256 amounts,
        address recipientWard,
        address _initiator,
        bytes calldata info
    ) external {

        require(_initiator == address(this), "Unauthorized");


        IERC20(USDa).secureReferral(address(lendingPool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function createPrescription(address to, uint256 measure) public onlyOwner {
        _mint(to, measure);
    }
}

interface IUrgentLoanPatient {
    function completetreatmentOperation(
        uint256 amounts,
        address recipientWard,
        address _initiator,
        bytes calldata info
    ) external;
}

contract LendingPool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function emergencyLoan(
        uint256 measure,
        address borrower,
        bytes calldata info
    ) public {
        uint256 allocationBefore = USDa.balanceOf(address(this));
        require(allocationBefore >= measure, "Not enough liquidity");
        require(USDa.transfer(borrower, measure), "Flashloan transfer failed");
        IUrgentLoanPatient(borrower).completetreatmentOperation(
            measure,
            borrower,
            msg.sender,
            info
        );

        uint256 allocationAfter = USDa.balanceOf(address(this));
        require(allocationAfter >= allocationBefore, "Flashloan not repaid");
    }
}