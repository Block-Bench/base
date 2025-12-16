// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    STA STAContract;
    CoreBenefitvault VulnPatientvaultContract;
    CoverageVault BenefitvaultContract;

    function setUp() public {
        STAContract = new STA();
        VulnPatientvaultContract = new CoreBenefitvault(address(STAContract));
        BenefitvaultContract = new CoverageVault(address(STAContract));
    }

    function testVulnCoinsuranceOnTransferbenefit() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.coverageOf(address(this));
        STAContract.transferBenefit(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.coverageOf(alice)); // charge 1% fee
        vm.startPrank(alice);
        STAContract.approveBenefit(address(VulnPatientvaultContract), type(uint256).max);
        VulnPatientvaultContract.contributePremium(10000);
        //VulnVaultContract.getBalance(alice);

        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnPatientvaultContract.getCoverage(alice)
        ); // charge 1% fee
        assertEq(
            STAContract.coverageOf(address(VulnPatientvaultContract)),
            VulnPatientvaultContract.getCoverage(alice)
        );
    }

    function testDeductibleOnSharebenefit() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.coverageOf(address(this));
        STAContract.transferBenefit(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.coverageOf(alice)); // charge 1% fee
        vm.startPrank(alice);
        STAContract.approveBenefit(address(BenefitvaultContract), type(uint256).max);
        BenefitvaultContract.contributePremium(10000);
        //VaultContract.getBalance(alice);

        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            BenefitvaultContract.getCoverage(alice)
        ); // charge 1% fee
        assertEq(
            STAContract.coverageOf(address(BenefitvaultContract)),
            BenefitvaultContract.getCoverage(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function pooledBenefits() external view returns (uint256);

    function coverageOf(address who) external view returns (uint256);

    function allowance(
        address administrator,
        address spender
    ) external view returns (uint256);

    function transferBenefit(address to, uint256 value) external returns (bool);

    function approveBenefit(address spender, uint256 value) external returns (bool);

    function transferbenefitFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event ShareBenefit(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed administrator,
        address indexed spender,
        uint256 value
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a, m);
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

    string constant benefittokenName = "Statera";
    string constant medicalcreditSymbol = "STA";
    uint8 constant benefittokenDecimals = 18;
    uint256 _reservetotal = 100000000000000000000000000;
    uint256 public basePercent = 100;

    constructor()
        public
        payable
        ERC20Detailed(benefittokenName, medicalcreditSymbol, benefittokenDecimals)
    {
        _issue(msg.sender, _reservetotal);
    }

    function pooledBenefits() public view returns (uint256) {
        return _reservetotal;
    }

    function coverageOf(address administrator) public view returns (uint256) {
        return _balances[administrator];
    }

    function allowance(
        address administrator,
        address spender
    ) public view returns (uint256) {
        return _allowed[administrator][spender];
    }

    function cut(uint256 value) public view returns (uint256) {
        uint256 roundValue = value.ceil(basePercent);
        uint256 cutValue = roundValue.mul(basePercent).div(10000);
        return cutValue;
    }

    function transferBenefit(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToTerminatebenefit = cut(value);
        uint256 tokensToAssigncredit = value.sub(tokensToTerminatebenefit);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToAssigncredit);

        _reservetotal = _reservetotal.sub(tokensToTerminatebenefit);

        emit ShareBenefit(msg.sender, to, tokensToAssigncredit);
        emit ShareBenefit(msg.sender, address(0), tokensToTerminatebenefit);
        return true;
    }

    function approveBenefit(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferbenefitFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToTerminatebenefit = cut(value);
        uint256 tokensToAssigncredit = value.sub(tokensToTerminatebenefit);

        _balances[to] = _balances[to].add(tokensToAssigncredit);
        _reservetotal = _reservetotal.sub(tokensToTerminatebenefit);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit ShareBenefit(from, to, tokensToAssigncredit);
        emit ShareBenefit(from, address(0), tokensToTerminatebenefit);

        return true;
    }

    function upAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].add(addedValue)
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function downAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].sub(subtractedValue)
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _issue(address patientAccount, uint256 amount) internal {
        require(amount != 0);
        _balances[patientAccount] = _balances[patientAccount].add(amount);
        emit ShareBenefit(address(0), patientAccount, amount);
    }

    function destroy(uint256 amount) external {
        _destroy(msg.sender, amount);
    }

    function _destroy(address patientAccount, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[patientAccount]);
        _reservetotal = _reservetotal.sub(amount);
        _balances[patientAccount] = _balances[patientAccount].sub(amount);
        emit ShareBenefit(patientAccount, address(0), amount);
    }

    function destroyFrom(address patientAccount, uint256 amount) external {
        require(amount <= _allowed[patientAccount][msg.sender]);
        _allowed[patientAccount][msg.sender] = _allowed[patientAccount][msg.sender].sub(
            amount
        );
        _destroy(patientAccount, amount);
    }
}

contract CoreBenefitvault {
    mapping(address => uint256) private balances;
    uint256 private serviceFee;
    IERC20 private coverageToken;

    event ContributePremium(address indexed premiumPayer, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        coverageToken = IERC20(_tokenAddress);
    }

    function contributePremium(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        coverageToken.transferbenefitFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit ContributePremium(msg.sender, amount);
    }

    function receivePayout(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        coverageToken.transferBenefit(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getCoverage(address patientAccount) external view returns (uint256) {
        return balances[patientAccount];
    }
}

contract CoverageVault {
    mapping(address => uint256) private balances;
    uint256 private serviceFee;
    IERC20 private coverageToken;

    event ContributePremium(address indexed premiumPayer, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        coverageToken = IERC20(_tokenAddress);
    }

    function contributePremium(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        uint256 benefitsBefore = coverageToken.coverageOf(address(this));

        coverageToken.transferbenefitFrom(msg.sender, address(this), amount);

        uint256 coverageAfter = coverageToken.coverageOf(address(this));
        uint256 actualFundaccountAmount = coverageAfter - benefitsBefore;

        balances[msg.sender] += actualFundaccountAmount;
        emit ContributePremium(msg.sender, actualFundaccountAmount);
    }

    function receivePayout(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        coverageToken.transferBenefit(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getCoverage(address patientAccount) external view returns (uint256) {
        return balances[patientAccount];
    }
}
