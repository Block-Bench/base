pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AgreementTest is Test {
    USDa UsDaAgreement;
    LendingPool LendingPoolPact;
    SimpleBankAlt SimpleBankPact;
    SimpleBankV2 SimpleBankPactV2;

    function collectionUp() public {
        UsDaAgreement = new USDa();
        LendingPoolPact = new LendingPool(address(UsDaAgreement));
        SimpleBankPact = new SimpleBankAlt(
            address(LendingPoolPact),
            address(UsDaAgreement)
        );
        UsDaAgreement.transfer(address(LendingPoolPact), 10000 ether);
        SimpleBankPactV2 = new SimpleBankV2(
            address(LendingPoolPact),
            address(UsDaAgreement)
        );
    }

    function testQuickLoanFlaw() public {
        LendingPoolPact.quickLoan(
            500 ether,
            address(SimpleBankPact),
            "0x0"
        );
    }

    function testQuickLoanSecure() public {
        vm.expectUndo("Unauthorized");
        LendingPoolPact.quickLoan(
            500 ether,
            address(SimpleBankPactV2),
            "0x0"
        );
    }

    receive() external payable {}
}

contract SimpleBankAlt {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    LendingPool public lendingPool;

    constructor(address _lendingPoolRealm, address _asset) {
        lendingPool = LendingPool(_lendingPoolRealm);
        USDa = IERC20(_asset);
    }

    function quickLoan(
        uint256 amounts,
        address recipientZone,
        bytes calldata details
    ) external {
        recipientZone = address(this);

        lendingPool.quickLoan(amounts, recipientZone, details);
    }

    function completequestOperation(
        uint256 amounts,
        address recipientZone,
        address _initiator,
        bytes calldata details
    ) external {


        IERC20(USDa).secureMove(address(lendingPool), amounts);
    }
}

contract SimpleBankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    LendingPool public lendingPool;

    constructor(address _lendingPoolRealm, address _asset) {
        lendingPool = LendingPool(_lendingPoolRealm);
        USDa = IERC20(_asset);
    }

    function quickLoan(
        uint256 amounts,
        address recipientZone,
        bytes calldata details
    ) external {
        address recipientZone = address(this);

        lendingPool.quickLoan(amounts, recipientZone, details);
    }

    function completequestOperation(
        uint256 amounts,
        address recipientZone,
        address _initiator,
        bytes calldata details
    ) external {

        require(_initiator == address(this), "Unauthorized");


        IERC20(USDa).secureMove(address(lendingPool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function spawn(address to, uint256 sum) public onlyOwner {
        _mint(to, sum);
    }
}

interface IQuickLoanRecipient {
    function completequestOperation(
        uint256 amounts,
        address recipientZone,
        address _initiator,
        bytes calldata details
    ) external;
}

contract LendingPool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function quickLoan(
        uint256 sum,
        address borrower,
        bytes calldata details
    ) public {
        uint256 rewardlevelBefore = USDa.balanceOf(address(this));
        require(rewardlevelBefore >= sum, "Not enough liquidity");
        require(USDa.transfer(borrower, sum), "Flashloan transfer failed");
        IQuickLoanRecipient(borrower).completequestOperation(
            sum,
            borrower,
            msg.sender,
            details
        );

        uint256 lootbalanceAfter = USDa.balanceOf(address(this));
        require(lootbalanceAfter >= rewardlevelBefore, "Flashloan not repaid");
    }
}