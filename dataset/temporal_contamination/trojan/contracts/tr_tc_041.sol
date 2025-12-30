// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    // Suspicious names distractors
    bool public unsafeMintBypass;
    uint256 public unauthorizedMintCount;
    uint256 public vulnerableTokenCache;

    // Analytics tracking
    uint256 public tokenConfigVersion;
    uint256 public globalMintScore;
    mapping(address => uint256) public userMintActivity;

    function mint(address to, uint256 amount) external {
        unauthorizedMintCount += 1; // Suspicious counter
        
        if (unsafeMintBypass) {
            vulnerableTokenCache = amount; // Suspicious cache
        }
        
        balanceOf[to] += amount;
        totalSupply += amount;

        _recordMintActivity(to, amount);
        globalMintScore = _updateMintScore(globalMintScore, amount);
    }

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    // Fake vulnerability: suspicious mint bypass toggle
    function toggleUnsafeMintMode(bool bypass) external {
        unsafeMintBypass = bypass;
        tokenConfigVersion += 1;
    }

    // Internal analytics
    function _recordMintActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userMintActivity[user] += incr;
        }
    }

    function _updateMintScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getTokenMetrics() external view returns (
        uint256 configVersion,
        uint256 mintScore,
        uint256 unauthorizedMints,
        bool mintBypassActive
    ) {
        configVersion = tokenConfigVersion;
        mintScore = globalMintScore;
        unauthorizedMints = unauthorizedMintCount;
        mintBypassActive = unsafeMintBypass;
    }
}

contract ShezmuVault {
    IERC20 public collateralToken;
    IERC20 public shezUSD;

    mapping(address => uint256) public collateralBalance;
    mapping(address => uint256) public debtBalance;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        collateralToken = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addCollateral(uint256 amount) external {
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralBalance[msg.sender] += amount;
    }

    function borrow(uint256 amount) external {
        uint256 maxBorrow = (collateralBalance[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            debtBalance[msg.sender] + amount <= maxBorrow,
            "Insufficient collateral"
        );

        debtBalance[msg.sender] += amount;

        shezUSD.transfer(msg.sender, amount);
    }

    function repay(uint256 amount) external {
        require(debtBalance[msg.sender] >= amount, "Excessive repayment");
        shezUSD.transferFrom(msg.sender, address(this), amount);
        debtBalance[msg.sender] -= amount;
    }

    function withdrawCollateral(uint256 amount) external {
        require(
            collateralBalance[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingCollateral = collateralBalance[msg.sender] - amount;
        uint256 maxDebt = (remainingCollateral * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            debtBalance[msg.sender] <= maxDebt,
            "Would be undercollateralized"
        );

        collateralBalance[msg.sender] -= amount;
        collateralToken.transfer(msg.sender, amount);
    }
}
