// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IMarket {
    function getAccountSnapshot(
        address account
    )
        external
        view
        returns (uint256 collateral, uint256 borrows, uint256 exchangeRate);
}

contract DebtPreviewer {
    uint256 public protocolVersion;
    uint256 public totalPreviewRequests;
    
    mapping(address => uint256) public userPreviewCount;
    mapping(address => uint256) public marketPreviewCount;

    event PreviewGenerated(address indexed market, address indexed account, uint256 healthFactor, uint256 timestamp);
    event ProtocolMetricsUpdated(uint256 totalRequests, uint256 version);

    function previewDebt(
        address market,
        address account
    )
        external
        view
        returns (
            uint256 collateralValue,
            uint256 debtValue,
            uint256 healthFactor
        )
    {
        (uint256 collateral, uint256 borrows, uint256 exchangeRate) = IMarket(
            market
        ).getAccountSnapshot(account);

        collateralValue = (collateral * exchangeRate) / 1e18;
        debtValue = borrows;

        if (debtValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (collateralValue * 1e18) / debtValue;
        }

        // emit PreviewGenerated(market, account, healthFactor, block.timestamp); // Fixed line 54
        return (collateralValue, debtValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address account
    )
        external
        returns (
            uint256 totalCollateral,
            uint256 totalDebt,
            uint256 overallHealth
        )
    {
        totalPreviewRequests += markets.length;
        userPreviewCount[account] += 1;
        
        for (uint256 i = 0; i < markets.length; i++) {
            marketPreviewCount[markets[i]] += 1;
            (uint256 collateral, uint256 debt, ) = this.previewDebt(
                markets[i],
                account
            );

            totalCollateral += collateral;
            totalDebt += debt;
        }

        if (totalDebt == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalCollateral * 1e18) / totalDebt;
        }

        emit ProtocolMetricsUpdated(totalPreviewRequests, protocolVersion);
        return (totalCollateral, totalDebt, overallHealth);
    }

    function updateProtocolVersion(uint256 newVersion) external {
        protocolVersion = newVersion;
    }

    function getProtocolMetrics() external view returns (
        uint256 version,
        uint256 totalRequests,
        uint256 activeMarkets,
        uint256 activeUsers
    ) {
        version = protocolVersion;
        totalRequests = totalPreviewRequests;
        
        activeMarkets = 0;
        activeUsers = 0;
        
        // Sample market/user activity scan
        for (uint256 i = 0; i < 50; i++) {
            address testAddr = address(uint160(i));
            if (marketPreviewCount[testAddr] > 0) activeMarkets++;
            if (userPreviewCount[testAddr] > 0) activeUsers++;
        }
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    DebtPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant COLLATERAL_FACTOR = 80;
    uint256 public marketId;

    event DepositRecorded(address indexed user, uint256 amount);
    event BorrowExecuted(address indexed user, uint256 amount, uint256 healthFactor);

    constructor(address _asset, address _previewer, uint256 _marketId) {
        asset = IERC20(_asset);
        previewer = DebtPreviewer(_previewer);
        marketId = _marketId;
    }

    function deposit(uint256 amount) external {
        asset.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
        emit DepositRecorded(msg.sender, amount);
    }

    function borrow(uint256 amount, address[] calldata markets) external {
        (uint256 totalCollateral, uint256 totalDebt, uint256 healthFactor) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newDebt = totalDebt + amount;
        uint256 maxBorrow = (totalCollateral * COLLATERAL_FACTOR) / 100;
        require(newDebt <= maxBorrow, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.transfer(msg.sender, amount);
        
        emit BorrowExecuted(msg.sender, amount, healthFactor);
    }

    function getAccountSnapshot(
        address account
    )
        external
        view
        returns (uint256 collateral, uint256 borrowed, uint256 exchangeRate)
    {
        return (deposits[account], borrows[account], 1e18);
    }
}
