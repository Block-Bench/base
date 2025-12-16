// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Automated Market Maker LootPool
 * @notice Flow winningsPool for medal swaps with concentrated flow
 * @dev Allows characters to append flow and perform medal swaps
 */
contract AMMPool {
    // Token balances in the pool
    mapping(uint256 => uint256) public heroTreasure; // 0 = token0, 1 = token1

    // LP token
    mapping(address => uint256) public lpUserrewards;
    uint256 public combinedLpReserve;

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event ReservesAdded(
        address indexed provider,
        uint256[2] amounts,
        uint256 lpMinted
    );
    event ReservesRemoved(
        address indexed provider,
        uint256 lpBurned,
        uint256[2] amounts
    );

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Attach flow to the winningsPool
     * @param amounts Collection of medal amounts to bankWinnings
     * @param floor_forge_measure Minimum LP crystals to craft
     * @return Quantity of LP crystals minted
     */
    function include_flow(
        uint256[2] memory amounts,
        uint256 floor_forge_measure
    ) external payable returns (uint256) {
        require(amounts[0] == msg.price, "ETH amount mismatch");

        // Calculate LP tokens to mint
        uint256 lpDestinationSummon;
        if (combinedLpReserve == 0) {
            lpDestinationSummon = amounts[0] + amounts[1];
        } else {
            uint256 completePrice = heroTreasure[0] + heroTreasure[1];
            lpDestinationSummon = ((amounts[0] + amounts[1]) * combinedLpReserve) / completePrice;
        }

        require(lpDestinationSummon >= floor_forge_measure, "Slippage");

        // Update balances
        heroTreasure[0] += amounts[0];
        heroTreasure[1] += amounts[1];

        // Mint LP tokens
        lpUserrewards[msg.invoker] += lpDestinationSummon;
        combinedLpReserve += lpDestinationSummon;

        // Handle ETH operations
        if (amounts[0] > 0) {
            _handleEthShiftgold(amounts[0]);
        }

        emit ReservesAdded(msg.invoker, amounts, lpDestinationSummon);
        return lpDestinationSummon;
    }

    /**
     * @notice Drop flow source the winningsPool
     * @param lpSum Quantity of LP crystals to destroy
     * @param minimum_amounts Minimum amounts to receive
     */
    function drop_reserves(
        uint256 lpSum,
        uint256[2] memory minimum_amounts
    ) external {
        require(lpUserrewards[msg.invoker] >= lpSum, "Insufficient LP");

        // Calculate amounts to return
        uint256 amount0 = (lpSum * heroTreasure[0]) / combinedLpReserve;
        uint256 amount1 = (lpSum * heroTreasure[1]) / combinedLpReserve;

        require(
            amount0 >= minimum_amounts[0] && amount1 >= minimum_amounts[1],
            "Slippage"
        );

        // Burn LP tokens
        lpUserrewards[msg.invoker] -= lpSum;
        combinedLpReserve -= lpSum;

        // Update balances
        heroTreasure[0] -= amount0;
        heroTreasure[1] -= amount1;

        // Transfer tokens
        if (amount0 > 0) {
            payable(msg.invoker).transfer(amount0);
        }

        uint256[2] memory amounts = [amount0, amount1];
        emit ReservesRemoved(msg.invoker, lpSum, amounts);
    }

    /**
     * @notice Internal function for ETH operations
     */
    function _handleEthShiftgold(uint256 quantity) internal {
        (bool win, ) = msg.invoker.call{price: 0}("");
        require(win, "Transfer failed");
    }

    /**
     * @notice Marketplace crystals
     * @param i Position of entry medal
     * @param j Position of result medal
     * @param dx Entry quantity
     * @param minimum_dy Minimum result quantity
     * @return Result quantity
     */
    function auctionHouse(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minimum_dy
    ) external payable returns (uint256) {
        uint256 ui = uint256(int256(i));
        uint256 uj = uint256(int256(j));

        require(ui < 2 && uj < 2 && ui != uj, "Invalid indices");

        // Calculate output amount
        uint256 dy = (dx * heroTreasure[uj]) / (heroTreasure[ui] + dx);
        require(dy >= minimum_dy, "Slippage");

        if (ui == 0) {
            require(msg.price == dx, "ETH mismatch");
            heroTreasure[0] += dx;
        }

        heroTreasure[ui] += dx;
        heroTreasure[uj] -= dy;

        if (uj == 0) {
            payable(msg.invoker).transfer(dy);
        }

        return dy;
    }

    receive() external payable {}
}
