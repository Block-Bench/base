pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool isListed;
        uint256 collateralFactor;
        mapping(address => uint256) accountCollateral;
        mapping(address => uint256) accountBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function enterMarkets(
        address[] calldata vTokens
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vTokens.length);
        for (uint256 i = 0; i < vTokens.length; i++) {
            markets[vTokens[i]].isListed = true;
            results[i] = 0;
        }
        return results;
    }

    function mint(address token, uint256 amount) external returns (uint256) {
        return _performMintImpl(msg.sender, token, amount);
    }

    function _performMintImpl(address _sender, address token, uint256 amount) internal returns (uint256) {
        IERC20(token).transferFrom(_sender, address(this), amount);
        uint256 price = oracle.getPrice(token);
        markets[token].accountCollateral[_sender] += amount;
        return 0;
    }

    function borrow(
        address borrowToken,
        uint256 borrowAmount
    ) external returns (uint256) {
        uint256 totalCollateralValue = 0;

        uint256 borrowPrice = oracle.getPrice(borrowToken);
        uint256 borrowValue = (borrowAmount * borrowPrice) / 1e18;

        uint256 maxBorrowValue = (totalCollateralValue * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(borrowValue <= maxBorrowValue, "Insufficient collateral");

        markets[borrowToken].accountBorrows[msg.sender] += borrowAmount;
        IERC20(borrowToken).transfer(msg.sender, borrowAmount);

        return 0;
    }

    function liquidate(
        address borrower,
        address repayToken,
        uint256 repayAmount,
        address collateralToken
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function getPrice(address token) external view override returns (uint256) {
        return prices[token];
    }

    function setPrice(address token, uint256 price) external {
        prices[token] = price;
    }
}