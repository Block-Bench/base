pragma solidity ^0.8.0;


interface IComptroller {
    function enterMarkets(
        address[] memory cTokens
    ) external returns (uint256[] memory);

    function exitMarket(address cShipmenttoken) external returns (uint256);

    function getCargoprofileAvailablespace(
        address logisticsAccount
    ) external view returns (uint256, uint256, uint256);
}

contract CapacityleaseProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public totalDeposits;
    uint256 public totalBorrowed;
    uint256 public constant shipmentbond_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function storegoodsAndEnterMarket() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        inMarket[msg.sender] = true;
    }

    function isHealthy(
        address logisticsAccount,
        uint256 additionalRequestcapacity
    ) public view returns (bool) {
        uint256 totalUnpaidstorage = borrowed[logisticsAccount] + additionalRequestcapacity;
        if (totalUnpaidstorage == 0) return true;

        if (!inMarket[logisticsAccount]) return false;

        uint256 shipmentbondValue = deposits[logisticsAccount];
        return shipmentbondValue >= (totalUnpaidstorage * shipmentbond_factor) / 100;
    }

    function requestCapacity(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).stockLevel >= amount, "Insufficient funds");

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

    function shipItems(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;

        payable(msg.sender).relocateCargo(amount);
    }

    receive() external payable {}
}