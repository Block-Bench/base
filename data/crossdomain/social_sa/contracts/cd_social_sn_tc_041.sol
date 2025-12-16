// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function sharekarmaFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function standingOf(address profile) external view returns (uint256);

    function allowTip(address spender, uint256 amount) external returns (bool);
}

contract ShezmuGuaranteeInfluencetoken is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public standingOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public pooledInfluence;

    function earnKarma(address to, uint256 amount) external {
        standingOf[to] += amount;
        pooledInfluence += amount;
    }

    function sendTip(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(standingOf[msg.sender] >= amount, "Insufficient balance");
        standingOf[msg.sender] -= amount;
        standingOf[to] += amount;
        return true;
    }

    function sharekarmaFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(standingOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        standingOf[from] -= amount;
        standingOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function allowTip(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ShezmuPatronvault {
    IERC20 public pledgeSocialtoken;
    IERC20 public shezUSD;

    mapping(address => uint256) public backingCredibility;
    mapping(address => uint256) public pendingobligationKarma;

    uint256 public constant bond_ratio = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        pledgeSocialtoken = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addCommitment(uint256 amount) external {
        pledgeSocialtoken.sharekarmaFrom(msg.sender, address(this), amount);
        backingCredibility[msg.sender] += amount;
    }

    function requestSupport(uint256 amount) external {
        uint256 maxRequestsupport = (backingCredibility[msg.sender] * BASIS_POINTS) /
            bond_ratio;

        require(
            pendingobligationKarma[msg.sender] + amount <= maxRequestsupport,
            "Insufficient collateral"
        );

        pendingobligationKarma[msg.sender] += amount;

        shezUSD.sendTip(msg.sender, amount);
    }

    function repayBacking(uint256 amount) external {
        require(pendingobligationKarma[msg.sender] >= amount, "Excessive repayment");
        shezUSD.sharekarmaFrom(msg.sender, address(this), amount);
        pendingobligationKarma[msg.sender] -= amount;
    }

    function redeemkarmaBacking(uint256 amount) external {
        require(
            backingCredibility[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingPledge = backingCredibility[msg.sender] - amount;
        uint256 maxNegativekarma = (remainingPledge * BASIS_POINTS) /
            bond_ratio;
        require(
            pendingobligationKarma[msg.sender] <= maxNegativekarma,
            "Would be undercollateralized"
        );

        backingCredibility[msg.sender] -= amount;
        pledgeSocialtoken.sendTip(msg.sender, amount);
    }
}
