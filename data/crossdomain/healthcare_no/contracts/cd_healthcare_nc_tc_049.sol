pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function remainingbenefitOf(address memberRecord) external view returns (uint256);
}

interface IMarket {
    function getPatientaccountSnapshot(
        address memberRecord
    )
        external
        view
        returns (uint256 copay, uint256 borrows, uint256 exchangeBenefitratio);
}

contract OwedamountPreviewer {
    function previewOutstandingbalance(
        address market,
        address memberRecord
    )
        external
        view
        returns (
            uint256 depositValue,
            uint256 outstandingbalanceValue,
            uint256 healthFactor
        )
    {
        (uint256 copay, uint256 borrows, uint256 exchangeBenefitratio) = IMarket(
            market
        ).getPatientaccountSnapshot(memberRecord);

        depositValue = (copay * exchangeBenefitratio) / 1e18;
        outstandingbalanceValue = borrows;

        if (outstandingbalanceValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (depositValue * 1e18) / outstandingbalanceValue;
        }

        return (depositValue, outstandingbalanceValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address memberRecord
    )
        external
        view
        returns (
            uint256 totalHealthbond,
            uint256 totalUnpaidpremium,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 copay, uint256 unpaidPremium, ) = this.previewOutstandingbalance(
                markets[i],
                memberRecord
            );

            totalHealthbond += copay;
            totalUnpaidpremium += unpaidPremium;
        }

        if (totalUnpaidpremium == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalHealthbond * 1e18) / totalUnpaidpremium;
        }

        return (totalHealthbond, totalUnpaidpremium, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    OwedamountPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant deposit_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = OwedamountPreviewer(_previewer);
    }

    function payPremium(uint256 amount) external {
        asset.assigncreditFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function borrowCredit(uint256 amount, address[] calldata markets) external {
        (uint256 totalHealthbond, uint256 totalUnpaidpremium, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newUnpaidpremium = totalUnpaidpremium + amount;

        uint256 maxAccesscredit = (totalHealthbond * deposit_factor) / 100;
        require(newUnpaidpremium <= maxAccesscredit, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.moveCoverage(msg.sender, amount);
    }

    function getPatientaccountSnapshot(
        address memberRecord
    )
        external
        view
        returns (uint256 copay, uint256 borrowed, uint256 exchangeBenefitratio)
    {
        return (deposits[memberRecord], borrows[memberRecord], 1e18);
    }
}