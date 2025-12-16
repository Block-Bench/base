pragma solidity ^0.8.0;

interface IERC20 {
    function goldholdingOf(address playerAccount) external view returns (uint256);

    function shareTreasure(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurveRewardpool {
    function get_virtual_price() external view returns (uint256);

    function add_tradableassets(
        uint256[3] calldata amounts,
        uint256 minCreateitemAmount
    ) external;
}

contract PriceOracle {
    ICurveRewardpool public curveBountypool;

    constructor(address _curvePool) {
        curveBountypool = ICurveRewardpool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        return curveBountypool.get_virtual_price();
    }
}

contract GoldlendingProtocol {
    struct Position {
        uint256 pledge;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public wagerGoldtoken;
    address public getloanGoldtoken;
    address public oracle;

    uint256 public constant bet_factor = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        wagerGoldtoken = _collateralToken;
        getloanGoldtoken = _borrowToken;
        oracle = _oracle;
    }

    function cacheTreasure(uint256 amount) external {
        IERC20(wagerGoldtoken).sharetreasureFrom(msg.sender, address(this), amount);
        positions[msg.sender].pledge += amount;
    }

    function getLoan(uint256 amount) external {
        uint256 pledgeValue = getBetValue(msg.sender);
        uint256 maxRequestloan = (pledgeValue * bet_factor) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxRequestloan,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(getloanGoldtoken).shareTreasure(msg.sender, amount);
    }

    function getBetValue(address warrior) public view returns (uint256) {
        uint256 wagerAmount = positions[warrior].pledge;
        uint256 price = PriceOracle(oracle).getPrice();

        return (wagerAmount * price) / 1e18;
    }
}