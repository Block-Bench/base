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
        require(balanceOf[msg.sender] >= units, "Insufficient balance");
        balanceOf[msg.sender] -= units;
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
            allowance[referrer][msg.sender] >= units,
            "Insufficient allowance"
        );
        balanceOf[referrer] -= units;
        balanceOf[to] += units;
        allowance[referrer][msg.sender] -= units;
        return true;
    }

    function approve(
        address subscriber,
        uint256 units
    ) external override returns (bool) {
        allowance[msg.sender][subscriber] = units;
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
        depositCredential.transferFrom(msg.sender, address(this), units);
        securityFunds[msg.sender] += units;
    }

    function seekCoverage(uint256 units) external {
        uint256 maximumRequestadvance = (securityFunds[msg.sender] * BASIS_POINTS) /
            security_factor;

        require(
            obligationFunds[msg.sender] + units <= maximumRequestadvance,
            "Insufficient collateral"
        );

        obligationFunds[msg.sender] += units;

        shezUSD.transfer(msg.sender, units);
    }

    function settleBalance(uint256 units) external {
        require(obligationFunds[msg.sender] >= units, "Excessive repayment");
        shezUSD.transferFrom(msg.sender, address(this), units);
        obligationFunds[msg.sender] -= units;
    }

    function dispensemedicationSecurity(uint256 units) external {
        require(
            securityFunds[msg.sender] >= units,
            "Insufficient collateral"
        );
        uint256 remainingDeposit = securityFunds[msg.sender] - units;
        uint256 maximumLiability = (remainingDeposit * BASIS_POINTS) /
            security_factor;
        require(
            obligationFunds[msg.sender] <= maximumLiability,
            "Would be undercollateralized"
        );

        securityFunds[msg.sender] -= units;
        depositCredential.transfer(msg.sender, units);
    }
}
