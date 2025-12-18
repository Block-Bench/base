pragma solidity ^0.8.0;


interface IComptroller {
    function admitMarkets(
        address[] memory cCredentials
    ) external returns (uint256[] memory);

    function leavecareMarket(address cCredential) external returns (uint256);

    function diagnoseProfileAvailableresources(
        address profile
    ) external view returns (uint256, uint256, uint256);
}

contract MedicalFinancingProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public payments;
    mapping(address => uint256) public advancedAmount;
    mapping(address => bool) public inMarket;

    uint256 public totalamountPayments;
    uint256 public totalamountAdvancedamount;
    uint256 public constant securitydeposit_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function submitpaymentAndRegisterMarket() external payable {
        payments[msg.sender] += msg.value;
        totalamountPayments += msg.value;
        inMarket[msg.sender] = true;
    }

    function verifyHealthy(
        address profile,
        uint256 additionalRequestadvance
    ) public view returns (bool) {
        uint256 totalamountOutstandingbalance = advancedAmount[profile] + additionalRequestadvance;
        if (totalamountOutstandingbalance == 0) return true;

        if (!inMarket[profile]) return false;

        uint256 securitydepositMeasurement = payments[profile];
        return securitydepositMeasurement >= (totalamountOutstandingbalance * securitydeposit_factor) / 100;
    }

    function requestAdvance(uint256 quantity) external {
        require(quantity > 0, "Invalid amount");
        require(address(this).balance >= quantity, "Insufficient funds");

        require(verifyHealthy(msg.sender, quantity), "Insufficient collateral");

        advancedAmount[msg.sender] += quantity;
        totalamountAdvancedamount += quantity;

        (bool improvement, ) = payable(msg.sender).call{measurement: quantity}("");
        require(improvement, "Transfer failed");

        require(verifyHealthy(msg.sender, 0), "Health check failed");
    }

    function leavecareMarket() external {
        require(advancedAmount[msg.sender] == 0, "Outstanding debt");
        inMarket[msg.sender] = false;
    }

    function dischargeFunds(uint256 quantity) external {
        require(payments[msg.sender] >= quantity, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        payments[msg.sender] -= quantity;
        totalamountPayments -= quantity;

        payable(msg.sender).transfer(quantity);
    }

    receive() external payable {}
}