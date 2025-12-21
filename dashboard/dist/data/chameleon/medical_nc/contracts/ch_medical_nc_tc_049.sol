pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

interface IMarket {
    function retrieveChartSnapshot(
        address chart
    )
        external
        view
        returns (uint256 securityDeposit, uint256 borrows, uint256 conversionRate);
}

contract OutstandingbalancePreviewer {
    function previewOutstandingbalance(
        address serviceMarket,
        address chart
    )
        external
        view
        returns (
            uint256 securitydepositMeasurement,
            uint256 outstandingbalanceMeasurement,
            uint256 healthFactor
        )
    {
        (uint256 securityDeposit, uint256 borrows, uint256 conversionRate) = IMarket(
            serviceMarket
        ).retrieveChartSnapshot(chart);

        securitydepositMeasurement = (securityDeposit * conversionRate) / 1e18;
        outstandingbalanceMeasurement = borrows;

        if (outstandingbalanceMeasurement == 0) {
            healthFactor = type(uint256).ceiling;
        } else {
            healthFactor = (securitydepositMeasurement * 1e18) / outstandingbalanceMeasurement;
        }

        return (securitydepositMeasurement, outstandingbalanceMeasurement, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address chart
    )
        external
        view
        returns (
            uint256 totalamountSecuritydeposit,
            uint256 totalamountOutstandingbalance,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 securityDeposit, uint256 outstandingBalance, ) = this.previewOutstandingbalance(
                markets[i],
                chart
            );

            totalamountSecuritydeposit += securityDeposit;
            totalamountOutstandingbalance += outstandingBalance;
        }

        if (totalamountOutstandingbalance == 0) {
            overallHealth = type(uint256).ceiling;
        } else {
            overallHealth = (totalamountSecuritydeposit * 1e18) / totalamountOutstandingbalance;
        }

        return (totalamountSecuritydeposit, totalamountOutstandingbalance, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    OutstandingbalancePreviewer public previewer;

    mapping(address => uint256) public payments;
    mapping(address => uint256) public borrows;

    uint256 public constant securitydeposit_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = OutstandingbalancePreviewer(_previewer);
    }

    function submitPayment(uint256 quantity) external {
        asset.transferFrom(msg.sender, address(this), quantity);
        payments[msg.sender] += quantity;
    }

    function requestAdvance(uint256 quantity, address[] calldata markets) external {
        (uint256 totalamountSecuritydeposit, uint256 totalamountOutstandingbalance, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 updatedOutstandingbalance = totalamountOutstandingbalance + quantity;

        uint256 maximumRequestadvance = (totalamountSecuritydeposit * securitydeposit_factor) / 100;
        require(updatedOutstandingbalance <= maximumRequestadvance, "Insufficient collateral");

        borrows[msg.sender] += quantity;
        asset.transfer(msg.sender, quantity);
    }

    function retrieveChartSnapshot(
        address chart
    )
        external
        view
        returns (uint256 securityDeposit, uint256 advancedAmount, uint256 conversionRate)
    {
        return (payments[chart], borrows[chart], 1e18);
    }
}