pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    SimpleInsurancepool SimpleBenefitpoolContract;
    MyHealthtoken MyCoveragetokenContract;

    function setUp() public {
        MyCoveragetokenContract = new MyHealthtoken();
        SimpleBenefitpoolContract = new SimpleInsurancepool(address(MyCoveragetokenContract));
    }

    function testFirstDepositbenefit() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyCoveragetokenContract.moveCoverage(alice, 1 ether + 1);
        MyCoveragetokenContract.moveCoverage(bob, 2 ether);

        vm.startPrank(alice);

        MyCoveragetokenContract.authorizeClaim(address(SimpleBenefitpoolContract), 1);
        SimpleBenefitpoolContract.addCoverage(1);


        MyCoveragetokenContract.moveCoverage(address(SimpleBenefitpoolContract), 1 ether);

        vm.stopPrank();
        vm.startPrank(bob);


        MyCoveragetokenContract.authorizeClaim(address(SimpleBenefitpoolContract), 2 ether);
        SimpleBenefitpoolContract.addCoverage(2 ether);
        vm.stopPrank();
        vm.startPrank(alice);

        MyCoveragetokenContract.creditsOf(address(SimpleBenefitpoolContract));


        SimpleBenefitpoolContract.withdrawFunds(1);
        assertEq(MyCoveragetokenContract.creditsOf(alice), 1.5 ether);
        console.log("Alice balance", MyCoveragetokenContract.creditsOf(alice));
    }

    receive() external payable {}
}

contract MyHealthtoken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _generatecredit(msg.sender, 10000 * 10 ** decimals());
    }

    function createBenefit(address to, uint256 amount) public onlyManager {
        _generatecredit(to, amount);
    }
}

contract SimpleInsurancepool {
    IERC20 public loanHealthtoken;
    uint public totalShares;

    mapping(address => uint) public creditsOf;

    constructor(address _loanToken) {
        loanHealthtoken = IERC20(_loanToken);
    }

    function addCoverage(uint amount) external {
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

    function withdrawFunds(uint shares) external {
        require(shares > 0, "Shares must be greater than zero");
        require(creditsOf[msg.sender] >= shares, "Insufficient balance");

        uint healthtokenAmount = (shares * loanHealthtoken.creditsOf(address(this))) /
            totalShares;

        creditsOf[msg.sender] -= shares;
        totalShares -= shares;

        require(loanHealthtoken.moveCoverage(msg.sender, healthtokenAmount), "Transfer failed");
    }
}