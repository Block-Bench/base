pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactSubmissionSingleParameters {
        address credentialIn;
        address credentialOut;
        uint24 consultationFee;
        address beneficiary;
        uint256 dueDate;
        uint256 quantityIn;
        uint256 quantityOutMinimum;
        uint160 sqrtServicecostBoundX96;
    }

    function exactSubmissionSingle(
        ExactSubmissionSingleParameters calldata settings
    ) external payable returns (uint256 quantityOut);
}

contract BedrockVault {
    IERC20 public immutable uniBTC;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable transferGuide;

    uint256 public totalamountEthDeposited;
    uint256 public totalamountUniBtcMinted;

    constructor(address _uniBTC, address _wbtc, address _router) {
        uniBTC = IERC20(_uniBTC);
        WBTC = IERC20(_wbtc);
        transferGuide = IUniswapV3Router(_router);
    }

    function issueCredential() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 uniBtcQuantity = msg.value;

        totalamountEthDeposited += msg.value;
        totalamountUniBtcMinted += uniBtcQuantity;

        uniBTC.transfer(msg.sender, uniBtcQuantity);
    }

    function claimResources(uint256 quantity) external {
        require(quantity > 0, "No amount specified");
        require(uniBTC.balanceOf(msg.sender) >= quantity, "Insufficient balance");

        uniBTC.transferFrom(msg.sender, address(this), quantity);

        uint256 ethQuantity = quantity;
        require(address(this).balance >= ethQuantity, "Insufficient ETH");

        payable(msg.sender).transfer(ethQuantity);
    }

    function retrieveConvertcredentialsRatio() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}