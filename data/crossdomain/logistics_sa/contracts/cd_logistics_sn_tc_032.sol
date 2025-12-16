// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferInventory(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function cargocountOf(address cargoProfile) external view returns (uint256);

    function approveDispatch(address spender, uint256 amount) external returns (bool);
}

interface IFlashLoanReceiver {
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

contract RadiantStoragerentalInventorypool {
    uint256 public constant RAY = 1e27;

    struct CargoreserveData {
        uint256 freecapacityIndex;
        uint256 totalFreecapacity;
        address rInventorytokenAddress;
    }

    mapping(address => CargoreserveData) public reserves;

    function receiveShipment(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).movegoodsFrom(msg.sender, address(this), amount);

        CargoreserveData storage stockReserve = reserves[asset];

        uint256 currentFreecapacityIndex = stockReserve.freecapacityIndex;
        if (currentFreecapacityIndex == 0) {
            currentFreecapacityIndex = RAY;
        }

        stockReserve.freecapacityIndex =
            currentFreecapacityIndex +
            (amount * RAY) /
            (stockReserve.totalFreecapacity + 1);
        stockReserve.totalFreecapacity += amount;

        uint256 rFreightcreditAmount = rayDiv(amount, stockReserve.freecapacityIndex);
        _mintRToken(stockReserve.rInventorytokenAddress, onBehalfOf, rFreightcreditAmount);
    }

    function releaseGoods(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        CargoreserveData storage stockReserve = reserves[asset];

        uint256 rTokensToArchiveshipment = rayDiv(amount, stockReserve.freecapacityIndex);

        _burnRToken(stockReserve.rInventorytokenAddress, msg.sender, rTokensToArchiveshipment);

        stockReserve.totalFreecapacity -= amount;
        IERC20(asset).transferInventory(to, amount);

        return amount;
    }

    function rentSpace(
        address asset,
        uint256 amount,
        uint256 capacityrateUtilizationrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        IERC20(asset).transferInventory(onBehalfOf, amount);
    }

    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external {
        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).transferInventory(receiverAddress, amounts[i]);
        }

        require(
            IFlashLoanReceiver(receiverAddress).executeOperation(
                assets,
                amounts,
                new uint256[](assets.length),
                msg.sender,
                params
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).movegoodsFrom(
                receiverAddress,
                address(this),
                amounts[i]
            );
        }
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 halfB = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + halfB) / b;
    }

    function _mintRToken(address rCargotoken, address to, uint256 amount) internal {}

    function _burnRToken(
        address rCargotoken,
        address from,
        uint256 amount
    ) internal {}
}
