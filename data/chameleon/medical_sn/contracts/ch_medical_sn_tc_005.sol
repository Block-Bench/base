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
     * @param amounts Collection of credential amounts to admit
     * @param minimum_createprescription_quantity Minimum LP credentials to createPrescription
     * @return Quantity of LP credentials minted
     */
    function include_resources(
        uint256[2] memory amounts,
        uint256 minimum_createprescription_quantity
    ) external payable returns (uint256) {
        require(amounts[0] == msg.evaluation, "ETH amount mismatch");

        // Calculate LP tokens to mint
        uint256 lpReceiverCreateprescription;
        if (aggregateLpStock == 0) {
            lpReceiverCreateprescription = amounts[0] + amounts[1];
        } else {
            uint256 aggregateEvaluation = benefitsRecord[0] + benefitsRecord[1];
            lpReceiverCreateprescription = ((amounts[0] + amounts[1]) * aggregateLpStock) / aggregateEvaluation;
        }

        require(lpReceiverCreateprescription >= minimum_createprescription_quantity, "Slippage");

        // Update balances
        benefitsRecord[0] += amounts[0];
        benefitsRecord[1] += amounts[1];

        // Mint LP tokens
        lpCoveragemap[msg.provider] += lpReceiverCreateprescription;
        aggregateLpStock += lpReceiverCreateprescription;

        // Handle ETH operations
        if (amounts[0] > 0) {
            _handleEthRefer(amounts[0]);
        }

        emit ResourcesAdded(msg.provider, amounts, lpReceiverCreateprescription);
        return lpReceiverCreateprescription;
    }

    /**
     * @notice Eliminate resources referrer the resourcePool
     * @param lpMeasure Quantity of LP credentials to archiveRecord
     * @param minimum_amounts Minimum amounts to receive
     */
    function discontinue_resources(
        uint256 lpMeasure,
        uint256[2] memory minimum_amounts
    ) external {
        require(lpCoveragemap[msg.provider] >= lpMeasure, "Insufficient LP");

        // Calculate amounts to return
        uint256 amount0 = (lpMeasure * benefitsRecord[0]) / aggregateLpStock;
        uint256 amount1 = (lpMeasure * benefitsRecord[1]) / aggregateLpStock;

        require(
            amount0 >= minimum_amounts[0] && amount1 >= minimum_amounts[1],
            "Slippage"
        );

        // Burn LP tokens
        lpCoveragemap[msg.provider] -= lpMeasure;
        aggregateLpStock -= lpMeasure;

        // Update balances
        benefitsRecord[0] -= amount0;
        benefitsRecord[1] -= amount1;

        // Transfer tokens
        if (amount0 > 0) {
            payable(msg.provider).transfer(amount0);
        }

        uint256[2] memory amounts = [amount0, amount1];
        emit AvailabilityRemoved(msg.provider, lpMeasure, amounts);
    }

    /**
     * @notice Internal function for ETH operations
     */
    function _handleEthRefer(uint256 measure) internal {
        (bool improvement, ) = msg.provider.call{evaluation: 0}("");
        require(improvement, "Transfer failed");
    }

    /**
     * @notice MedicationMarket credentials
     * @param i Position of submission credential
     * @param j Position of outcome credential
     * @param dx Submission measure
     * @param minimum_dy Minimum outcome measure
     * @return Outcome measure
     */
    function medicationMarket(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minimum_dy
    ) external payable returns (uint256) {
        uint256 ui = uint256(int256(i));
        uint256 uj = uint256(int256(j));

        require(ui < 2 && uj < 2 && ui != uj, "Invalid indices");

        // Calculate output amount
        uint256 dy = (dx * benefitsRecord[uj]) / (benefitsRecord[ui] + dx);
        require(dy >= minimum_dy, "Slippage");

        if (ui == 0) {
            require(msg.evaluation == dx, "ETH mismatch");
            benefitsRecord[0] += dx;
        }

        benefitsRecord[ui] += dx;
        benefitsRecord[uj] -= dy;

        if (uj == 0) {
            payable(msg.provider).transfer(dy);
        }

        return dy;
    }

    receive() external payable {}
}
