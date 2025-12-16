pragma solidity ^0.8.0;

interface IERC20 {
    function karmaOf(address socialProfile) external view returns (uint256);

    function passInfluence(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurveTippool {
    function get_virtual_price() external view returns (uint256);

    function add_liquidreputation(
        uint256[3] calldata amounts,
        uint256 minEarnkarmaAmount
    ) external;
}

contract PriceOracle {
    ICurveTippool public curveDonationpool;

    constructor(address _curvePool) {
        curveDonationpool = ICurveTippool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        return curveDonationpool.get_virtual_price();
    }
}

contract SocialcreditProtocol {
    struct Position {
        uint256 backing;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public pledgeReputationtoken;
    address public askforbackingInfluencetoken;
    address public oracle;

    uint256 public constant commitment_factor = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        pledgeReputationtoken = _collateralToken;
        askforbackingInfluencetoken = _borrowToken;
        oracle = _oracle;
    }

    function tip(uint256 amount) external {
        IERC20(pledgeReputationtoken).passinfluenceFrom(msg.sender, address(this), amount);
        positions[msg.sender].backing += amount;
    }

    function requestSupport(uint256 amount) external {
        uint256 backingValue = getBackingValue(msg.sender);
        uint256 maxSeekfunding = (backingValue * commitment_factor) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxSeekfunding,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(askforbackingInfluencetoken).passInfluence(msg.sender, amount);
    }

    function getBackingValue(address member) public view returns (uint256) {
        uint256 pledgeAmount = positions[member].backing;
        uint256 price = PriceOracle(oracle).getPrice();

        return (pledgeAmount * price) / 1e18;
    }
}