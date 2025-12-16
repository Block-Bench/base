pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

*/

contract AgreementTest is Test {
    USDa UsDaPolicy;
    LendingPool LendingPoolPolicy;
    SimpleBankAlt SimpleBankPolicy;
    SimpleBankV2 SimpleBankPolicyV2;

    function collectionUp() public {
        UsDaPolicy = new USDa();
        LendingPoolPolicy = new LendingPool(address(UsDaPolicy));
        SimpleBankPolicy = new SimpleBankAlt(
            address(LendingPoolPolicy),
            address(UsDaPolicy)
        );
        UsDaPolicy.transfer(address(LendingPoolPolicy), 10000 ether);
        SimpleBankPolicyV2 = new SimpleBankV2(
            address(LendingPoolPolicy),
            address(UsDaPolicy)
        );
    }

    function testUrgentLoanFlaw() public {
        LendingPoolPolicy.urgentLoan(
            500 ether,
            address(SimpleBankPolicy),
            "0x0"
        );
    }

    function testEmergencyLoanSecure() public {
        vm.expectReverse("Unauthorized");
        LendingPoolPolicy.urgentLoan(
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

    constructor(address _lendingPoolWard, address _asset) {
        lendingPool = LendingPool(_lendingPoolWard);
        USDa = IERC20(_asset);
    }

    function urgentLoan(
        uint256 amounts,
        address recipientLocation,
        bytes calldata record
    ) external {
        recipientLocation = address(this);

        lendingPool.urgentLoan(amounts, recipientLocation, record);
    }

    function completetreatmentOperation(
        uint256 amounts,
        address recipientLocation,
        address _initiator,
        bytes calldata record
    ) external {
        */


        IERC20(USDa).secureReferral(address(lendingPool), amounts);
    }
}

contract SimpleBankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    LendingPool public lendingPool;

    constructor(address _lendingPoolWard, address _asset) {
        lendingPool = LendingPool(_lendingPoolWard);
        USDa = IERC20(_asset);
    }

    function urgentLoan(
        uint256 amounts,
        address recipientLocation,
        bytes calldata record
    ) external {
        address recipientLocation = address(this);

        lendingPool.urgentLoan(amounts, recipientLocation, record);
    }

    function completetreatmentOperation(
        uint256 amounts,
        address recipientLocation,
        address _initiator,
        bytes calldata record
    ) external {

        require(_initiator == address(this), "Unauthorized");


        IERC20(USDa).secureReferral(address(lendingPool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.provider, 10000 * 10 ** decimals());
    }

    function generateRecord(address to, uint256 dosage) public onlyOwner {
        _mint(to, dosage);
    }
}

interface IEmergencyLoanPatient {
    function completetreatmentOperation(
        uint256 amounts,
        address recipientLocation,
        address _initiator,
        bytes calldata record
    ) external;
}

contract LendingPool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function urgentLoan(
        uint256 dosage,
        address borrower,
        bytes calldata record
    ) public {
        uint256 fundsBefore = USDa.balanceOf(address(this));
        require(fundsBefore >= dosage, "Not enough liquidity");
        require(USDa.transfer(borrower, dosage), "Flashloan transfer failed");
        IEmergencyLoanPatient(borrower).completetreatmentOperation(
            dosage,
            borrower,
            msg.provider,
            record
        );

        uint256 allocationAfter = USDa.balanceOf(address(this));
        require(allocationAfter >= fundsBefore, "Flashloan not repaid");
    }
}