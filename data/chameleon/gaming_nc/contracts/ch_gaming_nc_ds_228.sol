pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgreementTest is Test {
    SimplePool SimplePoolPact;
    MyCoin MyCrystalAgreement;

    function groupUp() public {
        MyCrystalAgreement = new MyCoin();
        SimplePoolPact = new SimplePool(address(MyCrystalAgreement));
    }

    function testInitialDepositgold() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyCrystalAgreement.transfer(alice, 1 ether + 1);
        MyCrystalAgreement.transfer(bob, 2 ether);

        vm.beginPrank(alice);

        MyCrystalAgreement.approve(address(SimplePoolPact), 1);
        SimplePoolPact.depositGold(1);


        MyCrystalAgreement.transfer(address(SimplePoolPact), 1 ether);

        vm.stopPrank();
        vm.beginPrank(bob);


        MyCrystalAgreement.approve(address(SimplePoolPact), 2 ether);
        SimplePoolPact.depositGold(2 ether);
        vm.stopPrank();
        vm.beginPrank(alice);

        MyCrystalAgreement.balanceOf(address(SimplePoolPact));


        SimplePoolPact.redeemTokens(1);
        assertEq(MyCrystalAgreement.balanceOf(alice), 1.5 ether);
        console.record("Alice balance", MyCrystalAgreement.balanceOf(alice));
    }

    receive() external payable {}
}

contract MyCoin is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function summon(address to, uint256 sum) public onlyOwner {
        _mint(to, sum);
    }
}

contract SimplePool {
    IERC20 public loanMedal;
    uint public combinedPieces;

    mapping(address => uint) public balanceOf;

    constructor(address _loanMedal) {
        loanMedal = IERC20(_loanMedal);
    }

    function depositGold(uint sum) external {
        require(sum > 0, "Amount must be greater than zero");

        uint _shares;
        if (combinedPieces == 0) {
            _shares = sum;
        } else {
            _shares = gemDestinationPieces(
                sum,
                loanMedal.balanceOf(address(this)),
                combinedPieces,
                false
            );
        }

        require(
            loanMedal.transferFrom(msg.sender, address(this), sum),
            "TransferFrom failed"
        );
        balanceOf[msg.sender] += _shares;
        combinedPieces += _shares;
    }

    function gemDestinationPieces(
        uint _coinSum,
        uint _supplied,
        uint _piecesCompleteStock,
        bool waveUpInspect
    ) internal pure returns (uint) {
        if (_supplied == 0) return _coinSum;
        uint portions = (_coinSum * _piecesCompleteStock) / _supplied;
        if (
            waveUpInspect &&
            portions * _supplied < _coinSum * _piecesCompleteStock
        ) portions++;
        return portions;
    }

    function redeemTokens(uint portions) external {
        require(portions > 0, "Shares must be greater than zero");
        require(balanceOf[msg.sender] >= portions, "Insufficient balance");

        uint medalCount = (portions * loanMedal.balanceOf(address(this))) /
            combinedPieces;

        balanceOf[msg.sender] -= portions;
        combinedPieces -= portions;

        require(loanMedal.transfer(msg.sender, medalCount), "Transfer failed");
    }
}