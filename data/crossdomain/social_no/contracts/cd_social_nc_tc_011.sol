pragma solidity ^0.8.0;


interface IERC777 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function reputationOf(address profile) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address profile,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract ReputationadvanceFundingpool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 reputationToken = IERC777(asset);

        require(reputationToken.shareKarma(address(this), amount), "Transfer failed");

        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    function claimEarnings(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 contributorCredibility = supplied[msg.sender][asset];
        require(contributorCredibility > 0, "No balance");

        uint256 withdrawtipsAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            withdrawtipsAmount = contributorCredibility;
        }
        require(withdrawtipsAmount <= contributorCredibility, "Insufficient balance");

        IERC777(asset).shareKarma(msg.sender, withdrawtipsAmount);

        supplied[msg.sender][asset] -= withdrawtipsAmount;
        totalSupplied[asset] -= withdrawtipsAmount;

        return withdrawtipsAmount;
    }

    function getSupplied(
        address contributor,
        address asset
    ) external view returns (uint256) {
        return supplied[contributor][asset];
    }
}