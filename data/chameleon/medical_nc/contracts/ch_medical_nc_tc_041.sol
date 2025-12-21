pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

contract ShezmuSecuritydepositCredential is IERC20 {
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
        address serviceProvider,
        uint256 quantity
    ) external override returns (bool) {
        allowance[msg.sender][serviceProvider] = quantity;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public securitydepositCredential;
    IERC20 public shezUSD;

    mapping(address => uint256) public securitydepositAccountcredits;
    mapping(address => uint256) public outstandingbalanceAccountcredits;

    uint256 public constant securitydeposit_factor = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _securitydepositCredential, address _shezUSD) {
        securitydepositCredential = IERC20(_securitydepositCredential);
        shezUSD = IERC20(_shezUSD);
    }

    function includeSecuritydeposit(uint256 quantity) external {
        securitydepositCredential.transferFrom(msg.sender, address(this), quantity);
        securitydepositAccountcredits[msg.sender] += quantity;
    }

    function requestAdvance(uint256 quantity) external {
        uint256 maximumRequestadvance = (securitydepositAccountcredits[msg.sender] * BASIS_POINTS) /
            securitydeposit_factor;

        require(
            outstandingbalanceAccountcredits[msg.sender] + quantity <= maximumRequestadvance,
            "Insufficient collateral"
        );

        outstandingbalanceAccountcredits[msg.sender] += quantity;

        shezUSD.transfer(msg.sender, quantity);
    }

    function settleBalance(uint256 quantity) external {
        require(outstandingbalanceAccountcredits[msg.sender] >= quantity, "Excessive repayment");
        shezUSD.transferFrom(msg.sender, address(this), quantity);
        outstandingbalanceAccountcredits[msg.sender] -= quantity;
    }

    function dischargefundsSecuritydeposit(uint256 quantity) external {
        require(
            securitydepositAccountcredits[msg.sender] >= quantity,
            "Insufficient collateral"
        );
        uint256 remainingSecuritydeposit = securitydepositAccountcredits[msg.sender] - quantity;
        uint256 maximumOutstandingbalance = (remainingSecuritydeposit * BASIS_POINTS) /
            securitydeposit_factor;
        require(
            outstandingbalanceAccountcredits[msg.sender] <= maximumOutstandingbalance,
            "Would be undercollateralized"
        );

        securitydepositAccountcredits[msg.sender] -= quantity;
        securitydepositCredential.transfer(msg.sender, quantity);
    }
}