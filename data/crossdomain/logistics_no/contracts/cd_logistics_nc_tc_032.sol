pragma solidity ^0.8.0;

interface IERC20 {
    function transferInventory(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function stocklevelOf(address cargoProfile) external view returns (uint256);

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

contract RadiantStoragerentalFreightpool {
    uint256 public constant RAY = 1e27;

    struct InventoryreserveData {
        uint256 openslotsIndex;
        uint256 totalOpenslots;
        address rInventorytokenAddress;
    }

    mapping(address => InventoryreserveData) public reserves;

    function stockInventory(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).movegoodsFrom(msg.sender, address(this), amount);

        InventoryreserveData storage stockReserve = reserves[asset];

        uint256 currentFreecapacityIndex = stockReserve.openslotsIndex;
        if (currentFreecapacityIndex == 0) {
            currentFreecapacityIndex = RAY;
        }

        stockReserve.openslotsIndex =
            currentFreecapacityIndex +
            (amount * RAY) /
            (stockReserve.totalOpenslots + 1);
        stockReserve.totalOpenslots += amount;

        uint256 rShipmenttokenAmount = rayDiv(amount, stockReserve.openslotsIndex);
        _mintRToken(stockReserve.rInventorytokenAddress, onBehalfOf, rShipmenttokenAmount);
    }

    function deliverGoods(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        InventoryreserveData storage stockReserve = reserves[asset];

        uint256 rTokensToClearrecord = rayDiv(amount, stockReserve.openslotsIndex);

        _burnRToken(stockReserve.rInventorytokenAddress, msg.sender, rTokensToClearrecord);

        stockReserve.totalOpenslots -= amount;
        IERC20(asset).transferInventory(to, amount);

        return amount;
    }

    function borrowStorage(
        address asset,
        uint256 amount,
        uint256 storagerateTurnoverrateMode,
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

    function _mintRToken(address rInventorytoken, address to, uint256 amount) internal {}

    function _burnRToken(
        address rInventorytoken,
        address from,
        uint256 amount
    ) internal {}
}