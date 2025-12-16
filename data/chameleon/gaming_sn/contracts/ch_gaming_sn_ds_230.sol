// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AgreementTest is Test {
    USDa UsDaAgreement;
    LendingPool LendingPoolPact;
    SimpleBankAlt SimpleBankPact;
    SimpleBankV2 SimpleBankAgreementV2;

    function groupUp() public {
        UsDaAgreement = new USDa();
        LendingPoolPact = new LendingPool(address(UsDaAgreement));
        SimpleBankPact = new SimpleBankAlt(
            address(LendingPoolPact),
            address(UsDaAgreement)
        );
        UsDaAgreement.transfer(address(LendingPoolPact), 10000 ether);
        SimpleBankAgreementV2 = new SimpleBankV2(
            address(LendingPoolPact),
            address(UsDaAgreement)
        );
    }

    function testInstantLoanFlaw() public {
        LendingPoolPact.instantLoan(
            500 ether,
            address(SimpleBankPact),
            "0x0"
        );
    }

    function testInstantLoanSecure() public {
        vm.expectUndo("Unauthorized");
        LendingPoolPact.instantLoan(
            500 ether,
            address(SimpleBankAgreementV2),
            "0x0"
        );
    }

    receive() external payable {}
}

contract SimpleBankAlt {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    LendingPool public lendingPool;

    constructor(address _lendingPoolZone, address _asset) {
        lendingPool = LendingPool(_lendingPoolZone);
        USDa = IERC20(_asset);
    }

    function instantLoan(
        uint256 amounts,
        address recipientLocation,
        bytes calldata info
    ) external {
        recipientLocation = address(this);

        lendingPool.instantLoan(amounts, recipientLocation, info);
    }

    function performactionOperation(
        uint256 amounts,
        address recipientLocation,
        address _initiator,
        bytes calldata info
    ) external {

        // transfer all borrowed assets back to the lending pool
        IERC20(USDa).secureMove(address(lendingPool), amounts);
    }
}

contract SimpleBankV2 {
    using SafeERC20 for IERC20;
    IERC20 public USDa;
    LendingPool public lendingPool;

    constructor(address _lendingPoolZone, address _asset) {
        lendingPool = LendingPool(_lendingPoolZone);
        USDa = IERC20(_asset);
    }

    function instantLoan(
        uint256 amounts,
        address recipientLocation,
        bytes calldata info
    ) external {
        address recipientLocation = address(this);

        lendingPool.instantLoan(amounts, recipientLocation, info);
    }

    function performactionOperation(
        uint256 amounts,
        address recipientLocation,
        address _initiator,
        bytes calldata info
    ) external {

        require(_initiator == address(this), "Unauthorized");

        // transfer all borrowed assets back to the lending pool
        IERC20(USDa).secureMove(address(lendingPool), amounts);
    }
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function craft(address to, uint256 total) public onlyOwner {
        _mint(to, total);
    }
}

interface IQuickLoanRecipient {
    function performactionOperation(
        uint256 amounts,
        address recipientLocation,
        address _initiator,
        bytes calldata info
    ) external;
}

contract LendingPool {
    IERC20 public USDa;

    constructor(address _USDA) {
        USDa = IERC20(_USDA);
    }

    function instantLoan(
        uint256 total,
        address borrower,
        bytes calldata info
    ) public {
        uint256 treasureamountBefore = USDa.balanceOf(address(this));
        require(treasureamountBefore >= total, "Not enough liquidity");
        require(USDa.transfer(borrower, total), "Flashloan transfer failed");
        IQuickLoanRecipient(borrower).performactionOperation(
            total,
            borrower,
            msg.sender,
            info
        );

        uint256 goldholdingAfter = USDa.balanceOf(address(this));
        require(goldholdingAfter >= treasureamountBefore, "Flashloan not repaid");
    }
}
