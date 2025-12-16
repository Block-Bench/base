// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    SimpleSupportpool SimpleSupportpoolContract;
    MyReputationtoken MySocialtokenContract;

    function setUp() public {
        MySocialtokenContract = new MyReputationtoken();
        SimpleSupportpoolContract = new SimpleSupportpool(address(MySocialtokenContract));
    }

    function testFirstContribute() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MySocialtokenContract.passInfluence(alice, 1 ether + 1);
        MySocialtokenContract.passInfluence(bob, 2 ether);

        vm.startPrank(alice);
        // Alice deposits 1 wei, gets 1 pool token
        MySocialtokenContract.authorizeGift(address(SimpleSupportpoolContract), 1);
        SimpleSupportpoolContract.tip(1);

        // Alice transfers 1 ether to the pool, inflating the pool token price
        MySocialtokenContract.passInfluence(address(SimpleSupportpoolContract), 1 ether);

        vm.stopPrank();
        vm.startPrank(bob);
        // Bob deposits 2 ether, gets 1 pool token due to inflated price
        // uint shares = _tokenAmount * _sharesTotalSupply / _supplied;
        // shares = 2000000000000000000 * 1 / 1000000000000000001 = 1.9999999999999999999 => round down to 1.
        MySocialtokenContract.authorizeGift(address(SimpleSupportpoolContract), 2 ether);
        SimpleSupportpoolContract.tip(2 ether);
        vm.stopPrank();
        vm.startPrank(alice);

        MySocialtokenContract.reputationOf(address(SimpleSupportpoolContract));

        // Alice withdraws and gets 1.5 ether, making a profit
        SimpleSupportpoolContract.redeemKarma(1);
        assertEq(MySocialtokenContract.reputationOf(alice), 1.5 ether);
        console.log("Alice balance", MySocialtokenContract.reputationOf(alice));
    }

    receive() external payable {}
}

contract MyReputationtoken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _gainreputation(msg.sender, 10000 * 10 ** decimals());
    }

    function earnKarma(address to, uint256 amount) public onlyModerator {
        _gainreputation(to, amount);
    }
}

contract SimpleSupportpool {
    IERC20 public loanKarmatoken;
    uint public totalShares;

    mapping(address => uint) public reputationOf;

    constructor(address _loanToken) {
        loanKarmatoken = IERC20(_loanToken);
    }

    function tip(uint amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint _shares;
        if (totalShares == 0) {
            _shares = amount;
        } else {
            _shares = karmatokenToShares(
                amount,
                loanKarmatoken.reputationOf(address(this)),
                totalShares,
                false
            );
        }

        require(
            loanKarmatoken.sendtipFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );
        reputationOf[msg.sender] += _shares;
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
        require(reputationOf[msg.sender] >= shares, "Insufficient balance");

        uint reputationtokenAmount = (shares * loanKarmatoken.reputationOf(address(this))) /
            totalShares;

        reputationOf[msg.sender] -= shares;
        totalShares -= shares;

        require(loanKarmatoken.passInfluence(msg.sender, reputationtokenAmount), "Transfer failed");
    }
}
