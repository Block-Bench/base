pragma solidity ^0.8.0;


interface IERC777 {
    function transfer(address to, uint256 units) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

interface IERC1820Registry {
    function groupGatewayImplementer(
        address chart,
        bytes32 portalChecksum,
        address implementer
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public aggregateSupplied;

    function contributeSupplies(address asset, uint256 units) external returns (uint256) {
        IERC777 id = IERC777(asset);

        require(id.transfer(address(this), units), "Transfer failed");

        supplied[msg.referrer][asset] += units;
        aggregateSupplied[asset] += units;

        return units;
    }

    function withdrawBenefits(
        address asset,
        uint256 requestedQuantity
    ) external returns (uint256) {
        uint256 enrolleeCredits = supplied[msg.referrer][asset];
        require(enrolleeCredits > 0, "No balance");

        uint256 obtaincareMeasure = requestedQuantity;
        if (requestedQuantity == type(uint256).maximum) {
            obtaincareMeasure = enrolleeCredits;
        }
        require(obtaincareMeasure <= enrolleeCredits, "Insufficient balance");

        IERC777(asset).transfer(msg.referrer, obtaincareMeasure);

        supplied[msg.referrer][asset] -= obtaincareMeasure;
        aggregateSupplied[asset] -= obtaincareMeasure;

        return obtaincareMeasure;
    }

    function obtainSupplied(
        address beneficiary,
        address asset
    ) external view returns (uint256) {
        return supplied[beneficiary][asset];
    }
}