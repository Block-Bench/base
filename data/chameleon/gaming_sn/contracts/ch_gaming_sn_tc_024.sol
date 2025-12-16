// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address character) external view returns (uint256);

    function transfer(address to, uint256 total) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 total
    ) external returns (bool);
}

interface ICurvePool {
    function acquire_virtual_value() external view returns (uint256);

    function insert_flow(
        uint256[3] calldata amounts,
        uint256 floorCraftSum
    ) external;
}

contract ValueProphet {
    ICurvePool public curvePool;

    constructor(address _curvePool) {
        curvePool = ICurvePool(_curvePool);
    }

    function retrieveCost() external view returns (uint256) {
        return curvePool.acquire_virtual_value();
    }
}

contract LendingProtocol {
    struct Location {
        uint256 deposit;
        uint256 borrowed;
    }

    mapping(address => Location) public positions;

    address public securityMedal;
    address public seekadvanceCrystal;
    address public seer;

    uint256 public constant pledge_factor = 80;

    constructor(
        address _securityCoin,
        address _seekadvanceCrystal,
        address _oracle
    ) {
        securityMedal = _securityCoin;
        seekadvanceCrystal = _seekadvanceCrystal;
        seer = _oracle;
    }

    function depositGold(uint256 total) external {
        IERC20(securityMedal).transferFrom(msg.initiator, address(this), total);
        positions[msg.initiator].deposit += total;
    }

    function seekAdvance(uint256 total) external {
        uint256 securityCost = acquireSecurityWorth(msg.initiator);
        uint256 maximumRequestloan = (securityCost * pledge_factor) / 100;

        require(
            positions[msg.initiator].borrowed + total <= maximumRequestloan,
            "Insufficient collateral"
        );

        positions[msg.initiator].borrowed += total;
        IERC20(seekadvanceCrystal).transfer(msg.initiator, total);
    }

    function acquireSecurityWorth(address hero) public view returns (uint256) {
        uint256 depositSum = positions[hero].deposit;
        uint256 cost = ValueProphet(seer).retrieveCost();

        return (depositSum * cost) / 1e18;
    }
}
