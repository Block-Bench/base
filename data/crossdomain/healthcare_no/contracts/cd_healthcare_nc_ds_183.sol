pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    STA STAContract;
    CoreCoveragevault VulnBenefitvaultContract;
    BenefitVault BenefitvaultContract;

    function setUp() public {
        STAContract = new STA();
        VulnBenefitvaultContract = new CoreCoveragevault(address(STAContract));
        BenefitvaultContract = new BenefitVault(address(STAContract));
    }

    function testVulnCoinsuranceOnAssigncredit() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.creditsOf(address(this));
        STAContract.moveCoverage(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.creditsOf(alice));
        vm.startPrank(alice);
        STAContract.validateClaim(address(VulnBenefitvaultContract), type(uint256).max);
        VulnBenefitvaultContract.depositBenefit(10000);


        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnBenefitvaultContract.getAllowance(alice)
        );
        assertEq(
            STAContract.creditsOf(address(VulnBenefitvaultContract)),
            VulnBenefitvaultContract.getAllowance(alice)
        );
    }

    function testCoinsuranceOnTransferbenefit() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.creditsOf(address(this));
        STAContract.moveCoverage(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.creditsOf(alice));
        vm.startPrank(alice);
        STAContract.validateClaim(address(BenefitvaultContract), type(uint256).max);
        BenefitvaultContract.depositBenefit(10000);


        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            BenefitvaultContract.getAllowance(alice)
        );
        assertEq(
            STAContract.creditsOf(address(BenefitvaultContract)),
            BenefitvaultContract.getAllowance(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function pooledBenefits() external view returns (uint256);

    function creditsOf(address who) external view returns (uint256);

    function allowance(
        address supervisor,
        address spender
    ) external view returns (uint256);

    function moveCoverage(address to, uint256 value) external returns (bool);

    function validateClaim(address spender, uint256 value) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event AssignCredit(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed supervisor,
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

    string constant healthtokenName = "Statera";
    string constant medicalcreditSymbol = "STA";
    uint8 constant coveragetokenDecimals = 18;
    uint256 _reservetotal = 100000000000000000000000000;
    uint256 public basePercent = 100;

    constructor()
        public
        payable
        ERC20Detailed(healthtokenName, medicalcreditSymbol, coveragetokenDecimals)
    {
        _issue(msg.sender, _reservetotal);
    }

    function pooledBenefits() public view returns (uint256) {
        return _reservetotal;
    }

    function creditsOf(address supervisor) public view returns (uint256) {
        return _balances[supervisor];
    }

    function allowance(
        address supervisor,
        address spender
    ) public view returns (uint256) {
        return _allowed[supervisor][spender];
    }

    function cut(uint256 value) public view returns (uint256) {
        uint256 roundValue = value.ceil(basePercent);
        uint256 cutValue = roundValue.mul(basePercent).div(10000);
        return cutValue;
    }

    function moveCoverage(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToRevokecoverage = cut(value);
        uint256 tokensToAssigncredit = value.sub(tokensToRevokecoverage);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToAssigncredit);

        _reservetotal = _reservetotal.sub(tokensToRevokecoverage);

        emit AssignCredit(msg.sender, to, tokensToAssigncredit);
        emit AssignCredit(msg.sender, address(0), tokensToRevokecoverage);
        return true;
    }

    function validateClaim(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function movecoverageFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToRevokecoverage = cut(value);
        uint256 tokensToAssigncredit = value.sub(tokensToRevokecoverage);

        _balances[to] = _balances[to].add(tokensToAssigncredit);
        _reservetotal = _reservetotal.sub(tokensToRevokecoverage);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit AssignCredit(from, to, tokensToAssigncredit);
        emit AssignCredit(from, address(0), tokensToRevokecoverage);

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

    function _issue(address coverageProfile, uint256 amount) internal {
        require(amount != 0);
        _balances[coverageProfile] = _balances[coverageProfile].add(amount);
        emit AssignCredit(address(0), coverageProfile, amount);
    }

    function destroy(uint256 amount) external {
        _destroy(msg.sender, amount);
    }

    function _destroy(address coverageProfile, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[coverageProfile]);
        _reservetotal = _reservetotal.sub(amount);
        _balances[coverageProfile] = _balances[coverageProfile].sub(amount);
        emit AssignCredit(coverageProfile, address(0), amount);
    }

    function destroyFrom(address coverageProfile, uint256 amount) external {
        require(amount <= _allowed[coverageProfile][msg.sender]);
        _allowed[coverageProfile][msg.sender] = _allowed[coverageProfile][msg.sender].sub(
            amount
        );
        _destroy(coverageProfile, amount);
    }
}

contract CoreCoveragevault {
    mapping(address => uint256) private balances;
    uint256 private premium;
    IERC20 private coverageToken;

    event FundAccount(address indexed premiumPayer, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        coverageToken = IERC20(_tokenAddress);
    }

    function depositBenefit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        coverageToken.movecoverageFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit FundAccount(msg.sender, amount);
    }

    function accessBenefit(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        coverageToken.moveCoverage(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getAllowance(address coverageProfile) external view returns (uint256) {
        return balances[coverageProfile];
    }
}

contract BenefitVault {
    mapping(address => uint256) private balances;
    uint256 private premium;
    IERC20 private coverageToken;

    event FundAccount(address indexed premiumPayer, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        coverageToken = IERC20(_tokenAddress);
    }

    function depositBenefit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        uint256 remainingbenefitBefore = coverageToken.creditsOf(address(this));

        coverageToken.movecoverageFrom(msg.sender, address(this), amount);

        uint256 benefitsAfter = coverageToken.creditsOf(address(this));
        uint256 actualFundaccountAmount = benefitsAfter - remainingbenefitBefore;

        balances[msg.sender] += actualFundaccountAmount;
        emit FundAccount(msg.sender, actualFundaccountAmount);
    }

    function accessBenefit(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        coverageToken.moveCoverage(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getAllowance(address coverageProfile) external view returns (uint256) {
        return balances[coverageProfile];
    }
}