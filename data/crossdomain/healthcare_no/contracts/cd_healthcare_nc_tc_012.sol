pragma solidity ^0.8.0;


interface IComptroller {
    function enterMarkets(
        address[] memory cTokens
    ) external returns (uint256[] memory);

    function exitMarket(address cBenefittoken) external returns (uint256);

    function getMemberrecordAvailablebenefit(
        address coverageProfile
    ) external view returns (uint256, uint256, uint256);
}

contract HealthcreditProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public totalDeposits;
    uint256 public totalBorrowed;
    uint256 public constant securitybond_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function contributepremiumAndEnterMarket() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        inMarket[msg.sender] = true;
    }

    function isHealthy(
        address coverageProfile,
        uint256 additionalRequestadvance
    ) public view returns (bool) {
        uint256 totalUnpaidpremium = borrowed[coverageProfile] + additionalRequestadvance;
        if (totalUnpaidpremium == 0) return true;

        if (!inMarket[coverageProfile]) return false;

        uint256 securitybondValue = deposits[coverageProfile];
        return securitybondValue >= (totalUnpaidpremium * securitybond_factor) / 100;
    }

    function requestAdvance(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).benefits >= amount, "Insufficient funds");

        require(isHealthy(msg.sender, amount), "Insufficient collateral");

        borrowed[msg.sender] += amount;
        totalBorrowed += amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        require(isHealthy(msg.sender, 0), "Health check failed");
    }

    function exitMarket() external {
        require(borrowed[msg.sender] == 0, "Outstanding debt");
        inMarket[msg.sender] = false;
    }

    function withdrawFunds(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;

        payable(msg.sender).moveCoverage(amount);
    }

    receive() external payable {}
}