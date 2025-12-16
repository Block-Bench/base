// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function treasurecountOf(address gamerProfile) external view returns (uint256);

    function shareTreasure(address to, uint256 amount) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICurveLootpool {
    function get_virtual_price() external view returns (uint256);

    function add_tradableassets(
        uint256[3] calldata amounts,
        uint256 minGeneratelootAmount
    ) external;
}

contract PriceOracle {
    ICurveLootpool public curveLootpool;

    constructor(address _curvePool) {
        curveLootpool = ICurveLootpool(_curvePool);
    }

    function getPrice() external view returns (uint256) {
        return curveLootpool.get_virtual_price();
    }
}

contract GoldlendingProtocol {
    struct Position {
        uint256 stake;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public stakeGamecoin;
    address public requestloanQuesttoken;
    address public oracle;

    uint256 public constant deposit_factor = 80;

    constructor(
        address _collateralToken,
        address _borrowToken,
        address _oracle
    ) {
        stakeGamecoin = _collateralToken;
        requestloanQuesttoken = _borrowToken;
        oracle = _oracle;
    }

    function cacheTreasure(uint256 amount) external {
        IERC20(stakeGamecoin).giveitemsFrom(msg.sender, address(this), amount);
        positions[msg.sender].stake += amount;
    }

    function requestLoan(uint256 amount) external {
        uint256 pledgeValue = getWagerValue(msg.sender);
        uint256 maxBorrowgold = (pledgeValue * deposit_factor) / 100;

        require(
            positions[msg.sender].borrowed + amount <= maxBorrowgold,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(requestloanQuesttoken).shareTreasure(msg.sender, amount);
    }

    function getWagerValue(address hero) public view returns (uint256) {
        uint256 betAmount = positions[hero].stake;
        uint256 price = PriceOracle(oracle).getPrice();

        return (betAmount * price) / 1e18;
    }
}
