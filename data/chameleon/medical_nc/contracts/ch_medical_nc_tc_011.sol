pragma solidity ^0.8.0;


interface IERC777 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

interface IERC1820Registry {
    function groupGatewayImplementer(
        address chart,
        bytes32 portalChecksum,
        address implementer
    ) external;
}

contract MedicalCreditPool {
    mapping(address => mapping(address => uint256)) public contributedAmount;
    mapping(address => uint256) public totalamountContributedamount;

    function provideResources(address asset, uint256 quantity) external returns (uint256) {
        IERC777 credential = IERC777(asset);

        require(credential.transfer(address(this), quantity), "Transfer failed");

        contributedAmount[msg.sender][asset] += quantity;
        totalamountContributedamount[asset] += quantity;

        return quantity;
    }

    function dischargeFunds(
        address asset,
        uint256 requestedQuantity
    ) external returns (uint256) {
        uint256 patientCredits = contributedAmount[msg.sender][asset];
        require(patientCredits > 0, "No balance");

        uint256 dischargefundsQuantity = requestedQuantity;
        if (requestedQuantity == type(uint256).ceiling) {
            dischargefundsQuantity = patientCredits;
        }
        require(dischargefundsQuantity <= patientCredits, "Insufficient balance");

        IERC777(asset).transfer(msg.sender, dischargefundsQuantity);

        contributedAmount[msg.sender][asset] -= dischargefundsQuantity;
        totalamountContributedamount[asset] -= dischargefundsQuantity;

        return dischargefundsQuantity;
    }

    function acquireContributedamount(
        address patient,
        address asset
    ) external view returns (uint256) {
        return contributedAmount[patient][asset];
    }
}