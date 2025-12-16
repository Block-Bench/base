pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function benefitsOf(address patientAccount) external view returns (uint256);

    function approveBenefit(address spender, uint256 amount) external returns (bool);
}

contract ShezmuHealthbondHealthtoken is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public benefitsOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public reserveTotal;

    function createBenefit(address to, uint256 amount) external {
        benefitsOf[to] += amount;
        reserveTotal += amount;
    }

    function assignCredit(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(benefitsOf[msg.sender] >= amount, "Insufficient balance");
        benefitsOf[msg.sender] -= amount;
        benefitsOf[to] += amount;
        return true;
    }

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(benefitsOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        benefitsOf[from] -= amount;
        benefitsOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function approveBenefit(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ShezmuCoveragevault {
    IERC20 public deductibleMedicalcredit;
    IERC20 public shezUSD;

    mapping(address => uint256) public depositAllowance;
    mapping(address => uint256) public unpaidpremiumRemainingbenefit;

    uint256 public constant copay_ratio = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        deductibleMedicalcredit = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addCopay(uint256 amount) external {
        deductibleMedicalcredit.transferbenefitFrom(msg.sender, address(this), amount);
        depositAllowance[msg.sender] += amount;
    }

    function accessCredit(uint256 amount) external {
        uint256 maxRequestadvance = (depositAllowance[msg.sender] * BASIS_POINTS) /
            copay_ratio;

        require(
            unpaidpremiumRemainingbenefit[msg.sender] + amount <= maxRequestadvance,
            "Insufficient collateral"
        );

        unpaidpremiumRemainingbenefit[msg.sender] += amount;

        shezUSD.assignCredit(msg.sender, amount);
    }

    function settleBalance(uint256 amount) external {
        require(unpaidpremiumRemainingbenefit[msg.sender] >= amount, "Excessive repayment");
        shezUSD.transferbenefitFrom(msg.sender, address(this), amount);
        unpaidpremiumRemainingbenefit[msg.sender] -= amount;
    }

    function accessbenefitHealthbond(uint256 amount) external {
        require(
            depositAllowance[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingSecuritybond = depositAllowance[msg.sender] - amount;
        uint256 maxOutstandingbalance = (remainingSecuritybond * BASIS_POINTS) /
            copay_ratio;
        require(
            unpaidpremiumRemainingbenefit[msg.sender] <= maxOutstandingbalance,
            "Would be undercollateralized"
        );

        depositAllowance[msg.sender] -= amount;
        deductibleMedicalcredit.assignCredit(msg.sender, amount);
    }
}