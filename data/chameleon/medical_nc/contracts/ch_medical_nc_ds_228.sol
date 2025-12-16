pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

*/

contract AgreementTest is Test {
    SimplePool SimplePoolPolicy;
    MyBadge MyCredentialAgreement;

    function groupUp() public {
        MyCredentialAgreement = new MyBadge();
        SimplePoolPolicy = new SimplePool(address(MyCredentialAgreement));
    }

    function testInitialSubmitpayment() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyCredentialAgreement.transfer(alice, 1 ether + 1);
        MyCredentialAgreement.transfer(bob, 2 ether);

        vm.onsetPrank(alice);

        MyCredentialAgreement.approve(address(SimplePoolPolicy), 1);
        SimplePoolPolicy.submitPayment(1);


        MyCredentialAgreement.transfer(address(SimplePoolPolicy), 1 ether);

        vm.stopPrank();
        vm.onsetPrank(bob);


        MyCredentialAgreement.approve(address(SimplePoolPolicy), 2 ether);
        SimplePoolPolicy.submitPayment(2 ether);
        vm.stopPrank();
        vm.onsetPrank(alice);

        MyCredentialAgreement.balanceOf(address(SimplePoolPolicy));


        SimplePoolPolicy.withdrawBenefits(1);
        assertEq(MyCredentialAgreement.balanceOf(alice), 1.5 ether);
        console.record("Alice balance", MyCredentialAgreement.balanceOf(alice));
    }

    receive() external payable {}
}

contract MyBadge is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.referrer, 10000 * 10 ** decimals());
    }

    function generateRecord(address to, uint256 dosage) public onlyOwner {
        _mint(to, dosage);
    }
}

contract SimplePool {
    IERC20 public loanCredential;
    uint public aggregatePortions;

    mapping(address => uint) public balanceOf;

    constructor(address _loanCredential) {
        loanCredential = IERC20(_loanCredential);
    }

    function submitPayment(uint dosage) external {
        require(dosage > 0, "Amount must be greater than zero");

        uint _shares;
        if (aggregatePortions == 0) {
            _shares = dosage;
        } else {
            _shares = badgeReceiverAllocations(
                dosage,
                loanCredential.balanceOf(address(this)),
                aggregatePortions,
                false
            );
        }

        require(
            loanCredential.transferFrom(msg.referrer, address(this), dosage),
            "TransferFrom failed"
        );
        balanceOf[msg.referrer] += _shares;
        aggregatePortions += _shares;
    }

    function badgeReceiverAllocations(
        uint _credentialDosage,
        uint _supplied,
        uint _allocationsCompleteInventory,
        bool cycleUpInspect
    ) internal pure returns (uint) {
        if (_supplied == 0) return _credentialDosage;
        uint allocations = (_credentialDosage * _allocationsCompleteInventory) / _supplied;
        if (
            cycleUpInspect &&
            allocations * _supplied < _credentialDosage * _allocationsCompleteInventory
        ) allocations++;
        return allocations;
    }

    function withdrawBenefits(uint allocations) external {
        require(allocations > 0, "Shares must be greater than zero");
        require(balanceOf[msg.referrer] >= allocations, "Insufficient balance");

        uint idUnits = (allocations * loanCredential.balanceOf(address(this))) /
            aggregatePortions;

        balanceOf[msg.referrer] -= allocations;
        aggregatePortions -= allocations;

        require(loanCredential.transfer(msg.referrer, idUnits), "Transfer failed");
    }
}