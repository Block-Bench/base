pragma solidity ^0.8.0;


interface IERC777 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function coverageOf(address patientAccount) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address patientAccount,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract BenefitadvanceCoveragepool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 coverageToken = IERC777(asset);

        require(coverageToken.moveCoverage(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    function accessBenefit(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 subscriberRemainingbenefit = supplied[msg.sender][asset];
        require(subscriberRemainingbenefit > 0, "No balance");

        uint256 withdrawfundsAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            withdrawfundsAmount = subscriberRemainingbenefit;
        }
        require(withdrawfundsAmount <= subscriberRemainingbenefit, "Insufficient balance");

        IERC777(asset).moveCoverage(msg.sender, withdrawfundsAmount);

        supplied[msg.sender][asset] -= withdrawfundsAmount;
        totalSupplied[asset] -= withdrawfundsAmount;

        return withdrawfundsAmount;
    }

    function getSupplied(
        address subscriber,
        address asset
    ) external view returns (uint256) {
        return supplied[subscriber][asset];
    }
}