pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

*/

contract AgreementTest is Test {
    SimplePool SimplePoolAgreement;
    MyCoin MyMedalAgreement;

    function groupUp() public {
        MyMedalAgreement = new MyCoin();
        SimplePoolAgreement = new SimplePool(address(MyMedalAgreement));
    }

    function testPrimaryDepositgold() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyMedalAgreement.transfer(alice, 1 ether + 1);
        MyMedalAgreement.transfer(bob, 2 ether);

        vm.openingPrank(alice);

        MyMedalAgreement.approve(address(SimplePoolAgreement), 1);
        SimplePoolAgreement.cachePrize(1);


        MyMedalAgreement.transfer(address(SimplePoolAgreement), 1 ether);

        vm.stopPrank();
        vm.openingPrank(bob);


        MyMedalAgreement.approve(address(SimplePoolAgreement), 2 ether);
        SimplePoolAgreement.cachePrize(2 ether);
        vm.stopPrank();
        vm.openingPrank(alice);

        MyMedalAgreement.balanceOf(address(SimplePoolAgreement));


        SimplePoolAgreement.retrieveRewards(1);
        assertEq(MyMedalAgreement.balanceOf(alice), 1.5 ether);
        console.record("Alice balance", MyMedalAgreement.balanceOf(alice));
    }

    receive() external payable {}
}

contract MyCoin is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.caster, 10000 * 10 ** decimals());
    }

    function forge(address to, uint256 sum) public onlyOwner {
        _mint(to, sum);
    }
}

contract SimplePool {
    IERC20 public loanCoin;
    uint public combinedPieces;

    mapping(address => uint) public balanceOf;

    constructor(address _loanGem) {
        loanCoin = IERC20(_loanGem);
    }

    function cachePrize(uint sum) external {
        require(sum > 0, "Amount must be greater than zero");

        uint _shares;
        if (combinedPieces == 0) {
            _shares = sum;
        } else {
            _shares = coinTargetSlices(
                sum,
                loanCoin.balanceOf(address(this)),
                combinedPieces,
                false
            );
        }

        require(
            loanCoin.transferFrom(msg.caster, address(this), sum),
            "TransferFrom failed"
        );
        balanceOf[msg.caster] += _shares;
        combinedPieces += _shares;
    }

    function coinTargetSlices(
        uint _coinQuantity,
        uint _supplied,
        uint _piecesCombinedStock,
        bool waveUpVerify
    ) internal pure returns (uint) {
        if (_supplied == 0) return _coinQuantity;
        uint pieces = (_coinQuantity * _piecesCombinedStock) / _supplied;
        if (
            waveUpVerify &&
            pieces * _supplied < _coinQuantity * _piecesCombinedStock
        ) pieces++;
        return pieces;
    }

    function retrieveRewards(uint pieces) external {
        require(pieces > 0, "Shares must be greater than zero");
        require(balanceOf[msg.caster] >= pieces, "Insufficient balance");

        uint crystalTotal = (pieces * loanCoin.balanceOf(address(this))) /
            combinedPieces;

        balanceOf[msg.caster] -= pieces;
        combinedPieces -= pieces;

        require(loanCoin.transfer(msg.caster, crystalTotal), "Transfer failed");
    }
}