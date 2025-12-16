pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 count) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 count
    ) external returns (bool);
}

interface ICurvePool {
    function obtain_virtual_value() external view returns (uint256);

    function append_reserves(
        uint256[3] calldata amounts,
        uint256 floorCraftQuantity
    ) external;
}

contract ValueProphet {
    ICurvePool public curvePool;

    constructor(address _curvePool) {
        curvePool = ICurvePool(_curvePool);
    }

    function acquireValue() external view returns (uint256) {
        return curvePool.obtain_virtual_value();
    }
}

contract LendingProtocol {
    struct Coordinates {
        uint256 pledge;
        uint256 borrowed;
    }

    mapping(address => Coordinates) public positions;

    address public depositCrystal;
    address public requestloanCrystal;
    address public seer;

    uint256 public constant pledge_factor = 80;

    constructor(
        address _depositCrystal,
        address _seekadvanceCoin,
        address _oracle
    ) {
        depositCrystal = _depositCrystal;
        requestloanCrystal = _seekadvanceCoin;
        seer = _oracle;
    }

    function cachePrize(uint256 count) external {
        IERC20(depositCrystal).transferFrom(msg.sender, address(this), count);
        positions[msg.sender].pledge += count;
    }

    function requestLoan(uint256 count) external {
        uint256 securityMagnitude = acquireDepositWorth(msg.sender);
        uint256 maximumRequestloan = (securityMagnitude * pledge_factor) / 100;

        require(
            positions[msg.sender].borrowed + count <= maximumRequestloan,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += count;
        IERC20(requestloanCrystal).transfer(msg.sender, count);
    }

    function acquireDepositWorth(address character) public view returns (uint256) {
        uint256 securitySum = positions[character].pledge;
        uint256 cost = ValueProphet(seer).acquireValue();

        return (securitySum * cost) / 1e18;
    }
}