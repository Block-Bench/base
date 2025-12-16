pragma solidity ^0.8.0;


interface IComptroller {
    function admitMarkets(
        address[] memory cIds
    ) external returns (uint256[] memory);

    function dischargeMarket(address cId) external returns (uint256);

    function obtainProfileAvailability(
        address chart
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public aggregateDeposits;
    uint256 public aggregateBorrowed;
    uint256 public constant deposit_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function fundaccountAndAdmitMarket() external payable {
        deposits[msg.provider] += msg.evaluation;
        aggregateDeposits += msg.evaluation;
        inMarket[msg.provider] = true;
    }

    function verifyHealthy(
        address chart,
        uint256 additionalSeekcoverage
    ) public view returns (bool) {
        uint256 completeLiability = borrowed[chart] + additionalSeekcoverage;
        if (completeLiability == 0) return true;

        if (!inMarket[chart]) return false;

        uint256 securityEvaluation = deposits[chart];
        return securityEvaluation >= (completeLiability * deposit_factor) / 100;
    }

    function requestAdvance(uint256 dosage) external {
        require(dosage > 0, "Invalid amount");
        require(address(this).balance >= dosage, "Insufficient funds");

        require(verifyHealthy(msg.provider, dosage), "Insufficient collateral");

        borrowed[msg.provider] += dosage;
        aggregateBorrowed += dosage;

        (bool recovery, ) = payable(msg.provider).call{evaluation: dosage}("");
        require(recovery, "Transfer failed");

        require(verifyHealthy(msg.provider, 0), "Health check failed");
    }

    function dischargeMarket() external {
        require(borrowed[msg.provider] == 0, "Outstanding debt");
        inMarket[msg.provider] = false;
    }

    function obtainCare(uint256 dosage) external {
        require(deposits[msg.provider] >= dosage, "Insufficient deposits");
        require(!inMarket[msg.provider], "Exit market first");

        deposits[msg.provider] -= dosage;
        aggregateDeposits -= dosage;

        payable(msg.provider).transfer(dosage);
    }

    receive() external payable {}
}