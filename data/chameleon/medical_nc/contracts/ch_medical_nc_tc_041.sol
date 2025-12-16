pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address payer, uint256 quantity) external returns (bool);
}

contract ShezmuSecurityBadge is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    function issueCredential(address to, uint256 quantity) external {
        balanceOf[to] += quantity;
        totalSupply += quantity;
    }

    function transfer(
        address to,
        uint256 quantity
    ) external override returns (bool) {
        require(balanceOf[msg.sender] >= quantity, "Insufficient balance");
        balanceOf[msg.sender] -= quantity;
        balanceOf[to] += quantity;
        return true;
    }

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external override returns (bool) {
        require(balanceOf[referrer] >= quantity, "Insufficient balance");
        require(
            allowance[referrer][msg.sender] >= quantity,
            "Insufficient allowance"
        );
        balanceOf[referrer] -= quantity;
        balanceOf[to] += quantity;
        allowance[referrer][msg.sender] -= quantity;
        return true;
    }

    function approve(
        address payer,
        uint256 quantity
    ) external override returns (bool) {
        allowance[msg.sender][payer] = quantity;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public depositId;
    IERC20 public shezUSD;

    mapping(address => uint256) public depositAllocation;
    mapping(address => uint256) public obligationBenefits;

    uint256 public constant deposit_factor = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _depositId, address _shezUSD) {
        depositId = IERC20(_depositId);
        shezUSD = IERC20(_shezUSD);
    }

    function attachDeposit(uint256 quantity) external {
        depositId.transferFrom(msg.sender, address(this), quantity);
        depositAllocation[msg.sender] += quantity;
    }

    function seekCoverage(uint256 quantity) external {
        uint256 ceilingRequestadvance = (depositAllocation[msg.sender] * BASIS_POINTS) /
            deposit_factor;

        require(
            obligationBenefits[msg.sender] + quantity <= ceilingRequestadvance,
            "Insufficient collateral"
        );

        obligationBenefits[msg.sender] += quantity;

        shezUSD.transfer(msg.sender, quantity);
    }

    function returnEquipment(uint256 quantity) external {
        require(obligationBenefits[msg.sender] >= quantity, "Excessive repayment");
        shezUSD.transferFrom(msg.sender, address(this), quantity);
        obligationBenefits[msg.sender] -= quantity;
    }

    function dispensemedicationDeposit(uint256 quantity) external {
        require(
            depositAllocation[msg.sender] >= quantity,
            "Insufficient collateral"
        );
        uint256 remainingSecurity = depositAllocation[msg.sender] - quantity;
        uint256 maximumObligation = (remainingSecurity * BASIS_POINTS) /
            deposit_factor;
        require(
            obligationBenefits[msg.sender] <= maximumObligation,
            "Would be undercollateralized"
        );

        depositAllocation[msg.sender] -= quantity;
        depositId.transfer(msg.sender, quantity);
    }
}