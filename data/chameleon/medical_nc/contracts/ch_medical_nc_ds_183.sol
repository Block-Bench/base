pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    STA StaAgreement;
    CoreVault VulnVaultPolicy;
    MedicalVault VaultAgreement;

    function groupUp() public {
        StaAgreement = new STA();
        VulnVaultPolicy = new CoreVault(address(StaAgreement));
        VaultAgreement = new MedicalVault(address(StaAgreement));
    }

    function testVulnDeductibleOnRelocatepatient() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        StaAgreement.balanceOf(address(this));
        StaAgreement.transfer(alice, 1000000);
        console.record("Alice's STA balance:", STAContract.balanceOf(alice));
        vm.startPrank(alice);
        STAContract.approve(address(VulnVaultContract), type(uint256).max);
        VulnVaultContract.deposit(10000);


        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnVaultPolicy.viewBenefits(alice)
        );
        assertEq(
            StaAgreement.balanceOf(address(VulnVaultPolicy)),
            VulnVaultPolicy.viewBenefits(alice)
        );
    }

    function testCopayOnMoverecords() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        StaAgreement.balanceOf(address(this));
        StaAgreement.transfer(alice, 1000000);
        console.record("Alice's STA balance:", STAContract.balanceOf(alice));
        vm.startPrank(alice);
        STAContract.approve(address(VaultContract), type(uint256).max);
        VaultContract.deposit(10000);


        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            VaultAgreement.viewBenefits(alice)
        );
        assertEq(
            StaAgreement.balanceOf(address(VaultAgreement)),
            VaultAgreement.viewBenefits(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(
        address owner,
        address subscriber
    ) external view returns (uint256);

    function transfer(address to, uint256 rating) external returns (bool);

    function approve(address subscriber, uint256 rating) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 rating
    ) external returns (bool);

    event Transfer(address indexed referrer, address indexed to, uint256 rating);
    event AccessGranted(
        address indexed owner,
        address indexed subscriber,
        uint256 rating
    );
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function insert(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = insert(a, m);
        uint256 d = sub(c, 1);
        return mul(div(d, m), m);
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract STA is ERC20Detailed {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    string constant credentialPatientname = "Statera";
    string constant badgeDesignation = "STA";
    uint8 constant badgePrecision = 18;
    uint256 _cumulativeInventory = 100000000000000000000000000;
    uint256 public basePortion = 100;

    constructor()
        public
        payable
        ERC20Detailed(credentialPatientname, badgeDesignation, badgePrecision)
    {
        _issue(msg.sender, _cumulativeInventory);
    }

    function totalSupply() public view returns (uint256) {
        return _cumulativeInventory;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(
        address owner,
        address subscriber
    ) public view returns (uint256) {
        return _allowed[owner][subscriber];
    }

    function cut(uint256 rating) public view returns (uint256) {
        uint256 sessionAssessment = rating.ceil(basePortion);
        uint256 cutEvaluation = sessionAssessment.mul(basePortion).div(10000);
        return cutEvaluation;
    }

    function transfer(address to, uint256 rating) public returns (bool) {
        require(rating <= _balances[msg.sender]);
        require(to != address(0));

        uint256 idsDestinationConsumedose = cut(rating);
        uint256 idsDestinationRelocatepatient = rating.sub(idsDestinationConsumedose);

        _balances[msg.sender] = _balances[msg.sender].sub(rating);
        _balances[to] = _balances[to].insert(idsDestinationRelocatepatient);

        _cumulativeInventory = _cumulativeInventory.sub(idsDestinationConsumedose);

        emit Transfer(msg.sender, to, idsDestinationRelocatepatient);
        emit Transfer(msg.sender, address(0), idsDestinationConsumedose);
        return true;
    }

    function approve(address subscriber, uint256 rating) public returns (bool) {
        require(subscriber != address(0));
        _allowed[msg.sender][subscriber] = rating;
        emit AccessGranted(msg.sender, subscriber, rating);
        return true;
    }

    function transferFrom(
        address referrer,
        address to,
        uint256 rating
    ) public returns (bool) {
        require(rating <= _balances[referrer]);
        require(rating <= _allowed[referrer][msg.sender]);
        require(to != address(0));

        _balances[referrer] = _balances[referrer].sub(rating);

        uint256 idsDestinationConsumedose = cut(rating);
        uint256 idsDestinationRelocatepatient = rating.sub(idsDestinationConsumedose);

        _balances[to] = _balances[to].insert(idsDestinationRelocatepatient);
        _cumulativeInventory = _cumulativeInventory.sub(idsDestinationConsumedose);

        _allowed[referrer][msg.sender] = _allowed[referrer][msg.sender].sub(rating);

        emit Transfer(referrer, to, idsDestinationRelocatepatient);
        emit Transfer(referrer, address(0), idsDestinationConsumedose);

        return true;
    }

    function upQuota(
        address subscriber,
        uint256 addedAssessment
    ) public returns (bool) {
        require(subscriber != address(0));
        _allowed[msg.sender][subscriber] = (
            _allowed[msg.sender][subscriber].insert(addedAssessment)
        );
        emit AccessGranted(msg.sender, subscriber, _allowed[msg.sender][subscriber]);
        return true;
    }

    function downAuthorization(
        address subscriber,
        uint256 subtractedRating
    ) public returns (bool) {
        require(subscriber != address(0));
        _allowed[msg.sender][subscriber] = (
            _allowed[msg.sender][subscriber].sub(subtractedRating)
        );
        emit AccessGranted(msg.sender, subscriber, _allowed[msg.sender][subscriber]);
        return true;
    }

    function _issue(address chart, uint256 quantity) internal {
        require(quantity != 0);
        _balances[chart] = _balances[chart].insert(quantity);
        emit Transfer(address(0), chart, quantity);
    }

    function destroy(uint256 quantity) external {
        _destroy(msg.sender, quantity);
    }

    function _destroy(address chart, uint256 quantity) internal {
        require(quantity != 0);
        require(quantity <= _balances[chart]);
        _cumulativeInventory = _cumulativeInventory.sub(quantity);
        _balances[chart] = _balances[chart].sub(quantity);
        emit Transfer(chart, address(0), quantity);
    }

    function destroySource(address chart, uint256 quantity) external {
        require(quantity <= _allowed[chart][msg.sender]);
        _allowed[chart][msg.sender] = _allowed[chart][msg.sender].sub(
            quantity
        );
        _destroy(chart, quantity);
    }
}

contract CoreVault {
    mapping(address => uint256) private benefitsRecord;
    uint256 private premium;
    IERC20 private credential;

    event ContributeFunds(address indexed depositor, uint256 quantity);
    event BenefitsDisbursed(address indexed patient, uint256 quantity);

    constructor(address _idLocation) {
        credential = IERC20(_idLocation);
    }

    function fundAccount(uint256 quantity) external {
        require(quantity > 0, "Deposit amount must be greater than zero");

        credential.transferFrom(msg.sender, address(this), quantity);
        benefitsRecord[msg.sender] += quantity;
        emit ContributeFunds(msg.sender, quantity);
    }

    function claimCoverage(uint256 quantity) external {
        require(quantity > 0, "Withdrawal amount must be greater than zero");
        require(quantity <= benefitsRecord[msg.sender], "Insufficient balance");

        benefitsRecord[msg.sender] -= quantity;
        credential.transfer(msg.sender, quantity);
        emit BenefitsDisbursed(msg.sender, quantity);
    }

    function viewBenefits(address chart) external view returns (uint256) {
        return benefitsRecord[chart];
    }
}

contract MedicalVault {
    mapping(address => uint256) private benefitsRecord;
    uint256 private premium;
    IERC20 private credential;

    event ContributeFunds(address indexed depositor, uint256 quantity);
    event BenefitsDisbursed(address indexed patient, uint256 quantity);

    constructor(address _idLocation) {
        credential = IERC20(_idLocation);
    }

    function fundAccount(uint256 quantity) external {
        require(quantity > 0, "Deposit amount must be greater than zero");

        uint256 allocationBefore = credential.balanceOf(address(this));

        credential.transferFrom(msg.sender, address(this), quantity);

        uint256 coverageAfter = credential.balanceOf(address(this));
        uint256 actualFundaccountDosage = coverageAfter - allocationBefore;

        benefitsRecord[msg.sender] += actualFundaccountDosage;
        emit ContributeFunds(msg.sender, actualFundaccountDosage);
    }

    function claimCoverage(uint256 quantity) external {
        require(quantity > 0, "Withdrawal amount must be greater than zero");
        require(quantity <= benefitsRecord[msg.sender], "Insufficient balance");

        benefitsRecord[msg.sender] -= quantity;
        credential.transfer(msg.sender, quantity);
        emit BenefitsDisbursed(msg.sender, quantity);
    }

    function viewBenefits(address chart) external view returns (uint256) {
        return benefitsRecord[chart];
    }
}