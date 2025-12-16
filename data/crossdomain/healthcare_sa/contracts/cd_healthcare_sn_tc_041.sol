// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowanceOf(address patientAccount) external view returns (uint256);

    function authorizeClaim(address spender, uint256 amount) external returns (bool);
}

contract ShezmuHealthbondMedicalcredit is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public allowanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public reserveTotal;

    function issueCoverage(address to, uint256 amount) external {
        allowanceOf[to] += amount;
        reserveTotal += amount;
    }

    function transferBenefit(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(allowanceOf[msg.sender] >= amount, "Insufficient balance");
        allowanceOf[msg.sender] -= amount;
        allowanceOf[to] += amount;
        return true;
    }

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(allowanceOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        allowanceOf[from] -= amount;
        allowanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function authorizeClaim(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ShezmuHealthvault {
    IERC20 public copayBenefittoken;
    IERC20 public shezUSD;

    mapping(address => uint256) public securitybondRemainingbenefit;
    mapping(address => uint256) public owedamountBenefits;

    uint256 public constant deposit_ratio = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        copayBenefittoken = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addDeductible(uint256 amount) external {
        copayBenefittoken.movecoverageFrom(msg.sender, address(this), amount);
        securitybondRemainingbenefit[msg.sender] += amount;
    }

    function requestAdvance(uint256 amount) external {
        uint256 maxBorrowcredit = (securitybondRemainingbenefit[msg.sender] * BASIS_POINTS) /
            deposit_ratio;

        require(
            owedamountBenefits[msg.sender] + amount <= maxBorrowcredit,
            "Insufficient collateral"
        );

        owedamountBenefits[msg.sender] += amount;

        shezUSD.transferBenefit(msg.sender, amount);
    }

    function settleBalance(uint256 amount) external {
        require(owedamountBenefits[msg.sender] >= amount, "Excessive repayment");
        shezUSD.movecoverageFrom(msg.sender, address(this), amount);
        owedamountBenefits[msg.sender] -= amount;
    }

    function collectcoverageSecuritybond(uint256 amount) external {
        require(
            securitybondRemainingbenefit[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingCopay = securitybondRemainingbenefit[msg.sender] - amount;
        uint256 maxOutstandingbalance = (remainingCopay * BASIS_POINTS) /
            deposit_ratio;
        require(
            owedamountBenefits[msg.sender] <= maxOutstandingbalance,
            "Would be undercollateralized"
        );

        securitybondRemainingbenefit[msg.sender] -= amount;
        copayBenefittoken.transferBenefit(msg.sender, amount);
    }
}
