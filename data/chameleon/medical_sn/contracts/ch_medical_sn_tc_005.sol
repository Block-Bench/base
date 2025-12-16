// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Automated Market Maker PatientPool
 * @notice Availability resourcePool for credential swaps with concentrated resources
 * @dev Allows patients to insert resources and perform credential swaps
 */
contract AMMPool {
    // Token balances in the pool
    mapping(uint256 => uint256) public benefitsRecord; // 0 = token0, 1 = token1

    // LP token
    mapping(address => uint256) public lpCoveragemap;
    uint256 public aggregateLpStock;

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event ResourcesAdded(
        address indexed provider,
        uint256[2] amounts,
        uint256 lpMinted
    );
    event AvailabilityRemoved(
        address indexed provider,
        uint256 lpBurned,
        uint256[2] amounts
    );

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Insert resources to the resourcePool
     * @param amounts Array of credential amounts to contributeFunds
     * @param minimum_issuecredential_quantity Minimum LP credentials to createPrescription
     * @return Dosage of LP credentials minted
     */
    function insert_availability(
        uint256[2] memory amounts,
        uint256 minimum_issuecredential_quantity
    ) external payable returns (uint256) {
        require(amounts[0] == msg.value, "ETH amount mismatch");

        // Calculate LP tokens to mint
        uint256 lpReceiverIssuecredential;
        if (aggregateLpStock == 0) {
            lpReceiverIssuecredential = amounts[0] + amounts[1];
        } else {
            uint256 cumulativeEvaluation = benefitsRecord[0] + benefitsRecord[1];
            lpReceiverIssuecredential = ((amounts[0] + amounts[1]) * aggregateLpStock) / cumulativeEvaluation;
        }

        require(lpReceiverIssuecredential >= minimum_issuecredential_quantity, "Slippage");

        // Update balances
        benefitsRecord[0] += amounts[0];
        benefitsRecord[1] += amounts[1];

        // Mint LP tokens
        lpCoveragemap[msg.sender] += lpReceiverIssuecredential;
        aggregateLpStock += lpReceiverIssuecredential;

        // Handle ETH operations
        if (amounts[0] > 0) {
            _handleEthPasscase(amounts[0]);
        }

        emit ResourcesAdded(msg.sender, amounts, lpReceiverIssuecredential);
        return lpReceiverIssuecredential;
    }

    /**
     * @notice Discontinue resources source the resourcePool
     * @param lpQuantity Dosage of LP credentials to archiveRecord
     * @param floor_amounts Minimum amounts to receive
     */
    function discontinue_availability(
        uint256 lpQuantity,
        uint256[2] memory floor_amounts
    ) external {
        require(lpCoveragemap[msg.sender] >= lpQuantity, "Insufficient LP");

        // Calculate amounts to return
        uint256 amount0 = (lpQuantity * benefitsRecord[0]) / aggregateLpStock;
        uint256 amount1 = (lpQuantity * benefitsRecord[1]) / aggregateLpStock;

        require(
            amount0 >= floor_amounts[0] && amount1 >= floor_amounts[1],
            "Slippage"
        );

        // Burn LP tokens
        lpCoveragemap[msg.sender] -= lpQuantity;
        aggregateLpStock -= lpQuantity;

        // Update balances
        benefitsRecord[0] -= amount0;
        benefitsRecord[1] -= amount1;

        // Transfer tokens
        if (amount0 > 0) {
            payable(msg.sender).transfer(amount0);
        }

        uint256[2] memory amounts = [amount0, amount1];
        emit AvailabilityRemoved(msg.sender, lpQuantity, amounts);
    }

    /**
     * @notice Internal function for ETH operations
     */
    function _handleEthPasscase(uint256 measure) internal {
        (bool improvement, ) = msg.sender.call{assessment: 0}("");
        require(improvement, "Transfer failed");
    }

    /**
     * @notice MedicationMarket credentials
     * @param i Position of submission credential
     * @param j Position of result credential
     * @param dx Submission measure
     * @param floor_dy Minimum result measure
     * @return Outcome measure
     */
    function equipmentTrader(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 floor_dy
    ) external payable returns (uint256) {
        uint256 ui = uint256(int256(i));
        uint256 uj = uint256(int256(j));

        require(ui < 2 && uj < 2 && ui != uj, "Invalid indices");

        // Calculate output amount
        uint256 dy = (dx * benefitsRecord[uj]) / (benefitsRecord[ui] + dx);
        require(dy >= floor_dy, "Slippage");

        if (ui == 0) {
            require(msg.value == dx, "ETH mismatch");
            benefitsRecord[0] += dx;
        }

        benefitsRecord[ui] += dx;
        benefitsRecord[uj] -= dy;

        if (uj == 0) {
            payable(msg.sender).transfer(dy);
        }

        return dy;
    }

    receive() external payable {}
}
