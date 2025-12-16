pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
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

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 liquidityIndex;
        uint256 totalLiquidity;
        address rTokenAddress;
    }

    mapping(address => ReserveData) public reserves;

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        ReserveData storage reserve = reserves[asset];

        uint256 currentLiquidityIndex = reserve.liquidityIndex;
        if (currentLiquidityIndex == 0) {
            currentLiquidityIndex = RAY;
        }

        reserve.liquidityIndex =
            currentLiquidityIndex +
            (amount * RAY) /
            (reserve.totalLiquidity + 1);
        reserve.totalLiquidity += amount;

        uint256 rTokenAmount = rayDiv(amount, reserve.liquidityIndex);
        _mintRToken(reserve.rTokenAddress, onBehalfOf, rTokenAmount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        ReserveData storage reserve = reserves[asset];

        uint256 rTokensToBurn = rayDiv(amount, reserve.liquidityIndex);

        _burnRToken(reserve.rTokenAddress, msg.sender, rTokensToBurn);

        reserve.totalLiquidity -= amount;
        IERC20(asset).transfer(to, amount);

        return amount;
    }

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        IERC20(asset).transfer(onBehalfOf, amount);
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
            IERC20(assets[i]).transfer(receiverAddress, amounts[i]);
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
            IERC20(assets[i]).transferFrom(
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

    function _mintRToken(address rToken, address to, uint256 amount) internal {}

    function _burnRToken(
        address rToken,
        address from,
        uint256 amount
    ) internal {}
}