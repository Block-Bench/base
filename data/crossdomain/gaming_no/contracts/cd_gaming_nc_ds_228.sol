pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    SimpleRewardpool SimplePrizepoolContract;
    MyGamecoin MyGoldtokenContract;

    function setUp() public {
        MyGoldtokenContract = new MyGamecoin();
        SimplePrizepoolContract = new SimpleRewardpool(address(MyGoldtokenContract));
    }

    function testFirstStashitems() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyGoldtokenContract.giveItems(alice, 1 ether + 1);
        MyGoldtokenContract.giveItems(bob, 2 ether);

        vm.startPrank(alice);

        MyGoldtokenContract.authorizeDeal(address(SimplePrizepoolContract), 1);
        SimplePrizepoolContract.storeLoot(1);


        MyGoldtokenContract.giveItems(address(SimplePrizepoolContract), 1 ether);

        vm.stopPrank();
        vm.startPrank(bob);


        MyGoldtokenContract.authorizeDeal(address(SimplePrizepoolContract), 2 ether);
        SimplePrizepoolContract.storeLoot(2 ether);
        vm.stopPrank();
        vm.startPrank(alice);

        MyGoldtokenContract.treasurecountOf(address(SimplePrizepoolContract));


        SimplePrizepoolContract.redeemGold(1);
        assertEq(MyGoldtokenContract.treasurecountOf(alice), 1.5 ether);
        console.log("Alice balance", MyGoldtokenContract.treasurecountOf(alice));
    }

    receive() external payable {}
}

contract MyGamecoin is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _generateloot(msg.sender, 10000 * 10 ** decimals());
    }

    function craftGear(address to, uint256 amount) public onlyDungeonmaster {
        _generateloot(to, amount);
    }
}

contract SimpleRewardpool {
    IERC20 public loanGamecoin;
    uint public totalShares;

    mapping(address => uint) public treasurecountOf;

    constructor(address _loanToken) {
        loanGamecoin = IERC20(_loanToken);
    }

    function storeLoot(uint amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint _shares;
        if (totalShares == 0) {
            _shares = amount;
        } else {
            _shares = gamecoinToShares(
                amount,
                loanGamecoin.treasurecountOf(address(this)),
                totalShares,
                false
            );
        }

        require(
            loanGamecoin.sendgoldFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );
        treasurecountOf[msg.sender] += _shares;
        totalShares += _shares;
    }

    function gamecoinToShares(
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

    function redeemGold(uint shares) external {
        require(shares > 0, "Shares must be greater than zero");
        require(treasurecountOf[msg.sender] >= shares, "Insufficient balance");

        uint gamecoinAmount = (shares * loanGamecoin.treasurecountOf(address(this))) /
            totalShares;

        treasurecountOf[msg.sender] -= shares;
        totalShares -= shares;

        require(loanGamecoin.giveItems(msg.sender, gamecoinAmount), "Transfer failed");
    }
}