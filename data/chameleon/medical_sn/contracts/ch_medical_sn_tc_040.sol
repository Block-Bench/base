// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address payer, uint256 quantity) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactIntakeSingleSettings {
        address badgeIn;
        address idOut;
        uint24 premium;
        address patient;
        uint256 expirationDate;
        uint256 unitsIn;
        uint256 unitsOutMinimum;
        uint160 sqrtCostCapX96;
    }

    function exactIntakeSingle(
        ExactIntakeSingleSettings calldata settings
    ) external payable returns (uint256 dosageOut);
}

contract BedrockVault {
    IERC20 public immutable uniBTC;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable patientRouter;

    uint256 public completeEthDeposited;
    uint256 public cumulativeUniBtcMinted;

    constructor(address _uniBTC, address _wbtc, address _router) {
        uniBTC = IERC20(_uniBTC);
        WBTC = IERC20(_wbtc);
        patientRouter = IUniswapV3Router(_router);
    }

    function issueCredential() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 uniBtcQuantity = msg.value;

        completeEthDeposited += msg.value;
        cumulativeUniBtcMinted += uniBtcQuantity;

        uniBTC.transfer(msg.sender, uniBtcQuantity);
    }

    function exchangeCredits(uint256 quantity) external {
        require(quantity > 0, "No amount specified");
        require(uniBTC.balanceOf(msg.sender) >= quantity, "Insufficient balance");

        uniBTC.transferFrom(msg.sender, address(this), quantity);

        uint256 ethUnits = quantity;
        require(address(this).balance >= ethUnits, "Insufficient ETH");

        payable(msg.sender).transfer(ethUnits);
    }

    function acquireExchangeRatio() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}
