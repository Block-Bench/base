pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    SimpleTippool SimpleSupportpoolContract;
    MyKarmatoken MyReputationtokenContract;

    function setUp() public {
        MyReputationtokenContract = new MyKarmatoken();
        SimpleSupportpoolContract = new SimpleTippool(address(MyReputationtokenContract));
    }

    function testFirstFund() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyReputationtokenContract.shareKarma(alice, 1 ether + 1);
        MyReputationtokenContract.shareKarma(bob, 2 ether);

        vm.startPrank(alice);

        MyReputationtokenContract.authorizeGift(address(SimpleSupportpoolContract), 1);
        SimpleSupportpoolContract.contribute(1);


        MyReputationtokenContract.shareKarma(address(SimpleSupportpoolContract), 1 ether);

        vm.stopPrank();
        vm.startPrank(bob);


        MyReputationtokenContract.authorizeGift(address(SimpleSupportpoolContract), 2 ether);
        SimpleSupportpoolContract.contribute(2 ether);
        vm.stopPrank();
        vm.startPrank(alice);

        MyReputationtokenContract.influenceOf(address(SimpleSupportpoolContract));


        SimpleSupportpoolContract.redeemKarma(1);
        assertEq(MyReputationtokenContract.influenceOf(alice), 1.5 ether);
        console.log("Alice balance", MyReputationtokenContract.influenceOf(alice));
    }

    receive() external payable {}
}

contract MyKarmatoken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _createcontent(msg.sender, 10000 * 10 ** decimals());
    }

    function buildInfluence(address to, uint256 amount) public onlyAdmin {
        _createcontent(to, amount);
    }
}

contract SimpleTippool {
    IERC20 public loanKarmatoken;
    uint public totalShares;

    mapping(address => uint) public influenceOf;

    constructor(address _loanToken) {
        loanKarmatoken = IERC20(_loanToken);
    }

    function contribute(uint amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint _shares;
        if (totalShares == 0) {
            _shares = amount;
        } else {
            _shares = karmatokenToShares(
                amount,
                loanKarmatoken.influenceOf(address(this)),
                totalShares,
                false
            );
        }

        require(
            loanKarmatoken.sendtipFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );
        influenceOf[msg.sender] += _shares;
        totalShares += _shares;
    }

    function karmatokenToShares(
        uint _tokenAmount,
        uint _supplied,
        uint _sharesTotalSupply,
        bool roundUpCheck
    ) internal pure returns (uint) {
        if (_supplied == 0) return _tokenAmount;
        uint shares = (_tokenAmount * _sharesTotalSupply) / _supplied;
        if (
            roundUpCheck &&
            shares * _supplied < _tokenAmount * _sharesTotalSupply
        ) shares++;
        return shares;
    }

    function redeemKarma(uint shares) external {
        require(shares > 0, "Shares must be greater than zero");
        require(influenceOf[msg.sender] >= shares, "Insufficient balance");

        uint karmatokenAmount = (shares * loanKarmatoken.influenceOf(address(this))) /
            totalShares;

        influenceOf[msg.sender] -= shares;
        totalShares -= shares;

        require(loanKarmatoken.shareKarma(msg.sender, karmatokenAmount), "Transfer failed");
    }
}