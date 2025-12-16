// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    SimpleBenefitpool SimpleBenefitpoolContract;
    MyCoveragetoken MyBenefittokenContract;

    function setUp() public {
        MyBenefittokenContract = new MyCoveragetoken();
        SimpleBenefitpoolContract = new SimpleBenefitpool(address(MyBenefittokenContract));
    }

    function testFirstContributepremium() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyBenefittokenContract.assignCredit(alice, 1 ether + 1);
        MyBenefittokenContract.assignCredit(bob, 2 ether);

        vm.startPrank(alice);
        // Alice deposits 1 wei, gets 1 pool token
        MyBenefittokenContract.permitPayout(address(SimpleBenefitpoolContract), 1);
        SimpleBenefitpoolContract.contributePremium(1);

        // Alice transfers 1 ether to the pool, inflating the pool token price
        MyBenefittokenContract.assignCredit(address(SimpleBenefitpoolContract), 1 ether);

        vm.stopPrank();
        vm.startPrank(bob);
        // Bob deposits 2 ether, gets 1 pool token due to inflated price
        // uint shares = _tokenAmount * _sharesTotalSupply / _supplied;
        // shares = 2000000000000000000 * 1 / 1000000000000000001 = 1.9999999999999999999 => round down to 1.
        MyBenefittokenContract.permitPayout(address(SimpleBenefitpoolContract), 2 ether);
        SimpleBenefitpoolContract.contributePremium(2 ether);
        vm.stopPrank();
        vm.startPrank(alice);

        MyBenefittokenContract.creditsOf(address(SimpleBenefitpoolContract));

        // Alice withdraws and gets 1.5 ether, making a profit
        SimpleBenefitpoolContract.receivePayout(1);
        assertEq(MyBenefittokenContract.creditsOf(alice), 1.5 ether);
        console.log("Alice balance", MyBenefittokenContract.creditsOf(alice));
    }

    receive() external payable {}
}

contract MyCoveragetoken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _issuecoverage(msg.sender, 10000 * 10 ** decimals());
    }

    function issueCoverage(address to, uint256 amount) public onlyManager {
        _issuecoverage(to, amount);
    }
}

contract SimpleBenefitpool {
    IERC20 public loanHealthtoken;
    uint public totalShares;

    mapping(address => uint) public creditsOf;

    constructor(address _loanToken) {
        loanHealthtoken = IERC20(_loanToken);
    }

    function contributePremium(uint amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint _shares;
        if (totalShares == 0) {
            _shares = amount;
        } else {
            _shares = healthtokenToShares(
                amount,
                loanHealthtoken.creditsOf(address(this)),
                totalShares,
                false
            );
        }

        require(
            loanHealthtoken.transferbenefitFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );
        creditsOf[msg.sender] += _shares;
        totalShares += _shares;
    }

    function healthtokenToShares(
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

    function receivePayout(uint shares) external {
        require(shares > 0, "Shares must be greater than zero");
        require(creditsOf[msg.sender] >= shares, "Insufficient balance");

        uint coveragetokenAmount = (shares * loanHealthtoken.creditsOf(address(this))) /
            totalShares;

        creditsOf[msg.sender] -= shares;
        totalShares -= shares;

        require(loanHealthtoken.assignCredit(msg.sender, coveragetokenAmount), "Transfer failed");
    }
}
