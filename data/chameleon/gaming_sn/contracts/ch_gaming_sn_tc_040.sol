// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address user, uint256 sum) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactEntrySingleParameters {
        address crystalIn;
        address coinOut;
        uint24 charge;
        address receiver;
        uint256 timeLimit;
        uint256 countIn;
        uint256 totalOutMinimum;
        uint160 sqrtValueCapX96;
    }

    function exactEntrySingle(
        ExactEntrySingleParameters calldata settings
    ) external payable returns (uint256 sumOut);
}

contract BedrockVault {
    IERC20 public immutable uniBTC;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable pathFinder;

    uint256 public fullEthDeposited;
    uint256 public combinedUniBtcMinted;

    constructor(address _uniBTC, address _wbtc, address _router) {
        uniBTC = IERC20(_uniBTC);
        WBTC = IERC20(_wbtc);
        pathFinder = IUniswapV3Router(_router);
    }

    function forge() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 uniBtcQuantity = msg.value;

        fullEthDeposited += msg.value;
        combinedUniBtcMinted += uniBtcQuantity;

        uniBTC.transfer(msg.sender, uniBtcQuantity);
    }

    function convertPrize(uint256 sum) external {
        require(sum > 0, "No amount specified");
        require(uniBTC.balanceOf(msg.sender) >= sum, "Insufficient balance");

        uniBTC.transferFrom(msg.sender, address(this), sum);

        uint256 ethCount = sum;
        require(address(this).balance >= ethCount, "Insufficient ETH");

        payable(msg.sender).transfer(ethCount);
    }

    function obtainExchangeFactor() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}
