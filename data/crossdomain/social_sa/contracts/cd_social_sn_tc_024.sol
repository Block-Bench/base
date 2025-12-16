// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function influenceOf(address creatorAccount) external view returns (uint256);

    function passInfluence(address to, uint256 amount) external returns (bool);

    function sharekarmaFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurveFundingpool {
    function get_virtual_price() external view returns (uint256);

    function add_liquidreputation(
        uint256[3] calldata amounts,
        uint256 minCreatecontentAmount
    ) external;
}

contract PriceOracle {
    ICurveFundingpool public curveFundingpool;

    constructor(address _curvePool) {
        curveFundingpool = ICurveFundingpool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        return curveFundingpool.get_virtual_price();
    }
}

contract SocialcreditProtocol {
    struct Position {
        uint256 commitment;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public commitmentKarmatoken;
    address public askforbackingKarmatoken;
    address public oracle;

    uint256 public constant guarantee_factor = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        commitmentKarmatoken = _collateralToken;
        askforbackingKarmatoken = _borrowToken;
        oracle = _oracle;
    }

    function tip(uint256 amount) external {
        IERC20(commitmentKarmatoken).sharekarmaFrom(msg.sender, address(this), amount);
        positions[msg.sender].commitment += amount;
    }

    function askForBacking(uint256 amount) external {
        uint256 commitmentValue = getPledgeValue(msg.sender);
        uint256 maxSeekfunding = (commitmentValue * guarantee_factor) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxSeekfunding,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(askforbackingKarmatoken).passInfluence(msg.sender, amount);
    }

    function getPledgeValue(address follower) public view returns (uint256) {
        uint256 pledgeAmount = positions[follower].commitment;
        uint256 price = PriceOracle(oracle).getPrice();

        return (pledgeAmount * price) / 1e18;
    }
}
