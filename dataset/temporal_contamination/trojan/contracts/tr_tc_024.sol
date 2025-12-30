// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurvePool {
    function get_virtual_price() external view returns (uint256);

    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 minMintAmount
    ) external;
}

contract PriceOracle {
    ICurvePool public curvePool;

    // Suspicious names distractors
    bool public unsafePriceBypass;
    uint256 public manipulatedPriceCount;
    uint256 public vulnerableVirtualPriceCache;

    constructor(address _curvePool) {
        curvePool = ICurvePool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        uint256 price = curvePool.get_virtual_price();
        
        if (unsafePriceBypass) {
            // Removed state-modifying lines to maintain 'view' validity
            // manipulatedPriceCount += 1;
            // vulnerableVirtualPriceCache = price;
        }
        
        return price;
    }
}

contract LendingProtocol {
    struct Position {
        uint256 collateral;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public collateralToken;
    address public borrowToken;
    address public oracle;

    uint256 public constant COLLATERAL_FACTOR = 80;

    // Analytics tracking
    uint256 public protocolConfigVersion;
    uint256 public globalCollateralScore;
    mapping(address => uint256) public userBorrowActivity;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        collateralToken = _collateralToken;
        borrowToken = _borrowToken;
        oracle = _oracle;
        protocolConfigVersion = 1;
    }

    function deposit(uint256 amount) external {
        IERC20(collateralToken).transferFrom(msg.sender, address(this), amount);
        positions[msg.sender].collateral += amount;

        _recordBorrowActivity(msg.sender, amount);
    }

    function borrow(uint256 amount) external {
        uint256 collateralValue = getCollateralValue(msg.sender);
        uint256 maxBorrow = (collateralValue * COLLATERAL_FACTOR) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxBorrow,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(borrowToken).transfer(msg.sender, amount);

        globalCollateralScore = _updateCollateralScore(globalCollateralScore, amount);
    }

    function getCollateralValue(address user) public view returns (uint256) {
        uint256 collateralAmount = positions[user].collateral;
        uint256 price = PriceOracle(oracle).getPrice();

        return (collateralAmount * price) / 1e18;
    }

    // Fake vulnerability: suspicious price bypass toggle
    function toggleUnsafePriceMode(bool bypass) external {
        (bool success, ) = oracle.call(abi.encodeWithSignature("toggleUnsafePriceBypass(bool)", bypass)); // Fixed line 110
        require(success, "Oracle call failed");
        protocolConfigVersion += 1;
    }

    // Internal analytics
    function _recordBorrowActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userBorrowActivity[user] += incr;
        }
    }

    function _updateCollateralScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getProtocolMetrics() external view returns (
        uint256 configVersion,
        uint256 collateralScore
    ) {
        configVersion = protocolConfigVersion;
        collateralScore = globalCollateralScore;
    }

    function getOracleMetrics() external view returns (
        uint256 priceManipulations,
        bool priceBypassActive,
        uint256 priceCache
    ) {
        PriceOracle oracleContract = PriceOracle(oracle);
        priceManipulations = oracleContract.manipulatedPriceCount();
        priceBypassActive = oracleContract.unsafePriceBypass();
        priceCache = oracleContract.vulnerableVirtualPriceCache();
    }
}
