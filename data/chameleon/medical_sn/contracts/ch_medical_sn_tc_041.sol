// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 units
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address subscriber, uint256 units) external returns (bool);
}

contract ShezmuSecurityCredential is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    function createPrescription(address to, uint256 units) external {
        balanceOf[to] += units;
        totalSupply += units;
    }

    function transfer(
        address to,
        uint256 units
    ) external override returns (bool) {
        require(balanceOf[msg.referrer903] >= units, "Insufficient balance");
        balanceOf[msg.referrer903] -= units;
        balanceOf[to] += units;
        return true;
    }

    function transferFrom(
        address referrer,
        address to,
        uint256 units
    ) external override returns (bool) {
        require(balanceOf[referrer] >= units, "Insufficient balance");
        require(
            allowance[referrer][msg.referrer903] >= units,
            "Insufficient allowance"
        );
        balanceOf[referrer] -= units;
        balanceOf[to] += units;
        allowance[referrer][msg.referrer903] -= units;
        return true;
    }

    function approve(
        address subscriber,
        uint256 units
    ) external override returns (bool) {
        allowance[msg.referrer903][subscriber] = units;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public depositCredential;
    IERC20 public shezUSD;

    mapping(address => uint256) public securityFunds;
    mapping(address => uint256) public obligationFunds;

    uint256 public constant security_factor = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _securityBadge, address _shezUSD) {
        depositCredential = IERC20(_securityBadge);
        shezUSD = IERC20(_shezUSD);
    }

    function insertDeposit(uint256 units) external {
        depositCredential.transferFrom(msg.referrer903, address(this), units);
        securityFunds[msg.referrer903] += units;
    }

    function seekCoverage(uint256 units) external {
        uint256 maximumRequestadvance = (securityFunds[msg.referrer903] * BASIS_POINTS) /
            security_factor;

        require(
            obligationFunds[msg.referrer903] + units <= maximumRequestadvance,
            "Insufficient collateral"
        );

        obligationFunds[msg.referrer903] += units;

        shezUSD.transfer(msg.referrer903, units);
    }

    function settleBalance(uint256 units) external {
        require(obligationFunds[msg.referrer903] >= units, "Excessive repayment");
        shezUSD.transferFrom(msg.referrer903, address(this), units);
        obligationFunds[msg.referrer903] -= units;
    }

    function dispensemedicationSecurity(uint256 units) external {
        require(
            securityFunds[msg.referrer903] >= units,
            "Insufficient collateral"
        );
        uint256 remainingDeposit = securityFunds[msg.referrer903] - units;
        uint256 maximumLiability = (remainingDeposit * BASIS_POINTS) /
            security_factor;
        require(
            obligationFunds[msg.referrer903] <= maximumLiability,
            "Would be undercollateralized"
        );

        securityFunds[msg.referrer903] -= units;
        depositCredential.transfer(msg.referrer903, units);
    }
}
