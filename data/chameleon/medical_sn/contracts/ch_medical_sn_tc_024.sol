// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 dosage
    ) external returns (bool);
}

interface ICurvePool {
    function diagnose_virtual_charge() external view returns (uint256);

    function append_availability(
        uint256[3] calldata amounts,
        uint256 minimumCreateprescriptionUnits
    ) external;
}

contract CostConsultant {
    ICurvePool public curvePool;

    constructor(address _curvePool) {
        curvePool = ICurvePool(_curvePool);
    }

    function retrieveCost() external view returns (uint256) {
        return curvePool.diagnose_virtual_charge();
    }
}

contract LendingProtocol {
    struct Assignment {
        uint256 security;
        uint256 borrowed;
    }

    mapping(address => Assignment) public positions;

    address public securityId;
    address public requestadvanceBadge;
    address public specialist;

    uint256 public constant deposit_factor = 80;

    constructor(
        address _securityId,
        address _requestadvanceBadge,
        address _oracle
    ) {
        securityId = _securityId;
        requestadvanceBadge = _requestadvanceBadge;
        specialist = _oracle;
    }

    function submitPayment(uint256 dosage) external {
        IERC20(securityId).transferFrom(msg.referrer324, address(this), dosage);
        positions[msg.referrer324].security += dosage;
    }

    function requestAdvance(uint256 dosage) external {
        uint256 depositEvaluation = acquireDepositEvaluation(msg.referrer324);
        uint256 ceilingRequestadvance = (depositEvaluation * deposit_factor) / 100;

        require(
            positions[msg.referrer324].borrowed + dosage <= ceilingRequestadvance,
            "Insufficient collateral"
        );

        positions[msg.referrer324].borrowed += dosage;
        IERC20(requestadvanceBadge).transfer(msg.referrer324, dosage);
    }

    function acquireDepositEvaluation(address member) public view returns (uint256) {
        uint256 securityQuantity = positions[member].security;
        uint256 charge = CostConsultant(specialist).retrieveCost();

        return (securityQuantity * charge) / 1e18;
    }
}
