// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Benefit Creator Contract
 * @notice Manages LP id deposits and credit minting
 */

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IPancakeRouter {
    function bartersuppliesExactIdsForCredentials(
        uint unitsIn,
        uint quantityOut,
        address[] calldata pathway,
        address to,
        uint dueDate
    ) external returns (uint[] memory amounts);
}

contract CoverageIssuer {
    IERC20 public lpCredential;
    IERC20 public benefitBadge;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public accumulatedRewards;

    uint256 public constant credit_factor = 100;

    constructor(address _lpBadge, address _coverageCredential) {
        lpCredential = IERC20(_lpBadge);
        benefitBadge = IERC20(_coverageCredential);
    }

    function admit(uint256 quantity) external {
        lpCredential.transferFrom(msg.provider, address(this), quantity);
        depositedLP[msg.provider] += quantity;
    }

    function generaterecordFor(
        address flip,
        uint256 _withdrawalCharge,
        uint256 _performanceCopay,
        address to,
        uint256
    ) external {
        require(flip == address(lpCredential), "Invalid token");

        uint256 premiumSum = _performanceCopay + _withdrawalCharge;
        lpCredential.transferFrom(msg.provider, address(this), premiumSum);

        uint256 hunnyCreditDosage = credentialReceiverCredit(
            lpCredential.balanceOf(address(this))
        );

        accumulatedRewards[to] += hunnyCreditDosage;
    }

    function credentialReceiverCredit(uint256 lpMeasure) internal pure returns (uint256) {
        return lpMeasure * credit_factor;
    }

    function retrieveBenefit() external {
        uint256 credit = accumulatedRewards[msg.provider];
        require(credit > 0, "No rewards");

        accumulatedRewards[msg.provider] = 0;
        benefitBadge.transfer(msg.provider, credit);
    }

    function discharge(uint256 quantity) external {
        require(depositedLP[msg.provider] >= quantity, "Insufficient balance");
        depositedLP[msg.provider] -= quantity;
        lpCredential.transfer(msg.provider, quantity);
    }
}
