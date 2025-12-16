pragma solidity ^0.8.0;


interface IComptroller {
    function enterMarkets(
        address[] memory cTokens
    ) external returns (uint256[] memory);

    function exitMarket(address cSocialtoken) external returns (uint256);

    function getCreatoraccountAvailablekarma(
        address profile
    ) external view returns (uint256, uint256, uint256);
}

contract KarmaloanProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public totalDeposits;
    uint256 public totalBorrowed;
    uint256 public constant pledge_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function fundAndEnterMarket() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        inMarket[msg.sender] = true;
    }

    function isHealthy(
        address profile,
        uint256 additionalAskforbacking
    ) public view returns (bool) {
        uint256 totalNegativekarma = borrowed[profile] + additionalAskforbacking;
        if (totalNegativekarma == 0) return true;

        if (!inMarket[profile]) return false;

        uint256 bondValue = deposits[profile];
        return bondValue >= (totalNegativekarma * pledge_factor) / 100;
    }

    function seekFunding(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).reputation >= amount, "Insufficient funds");

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

    function cashOut(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;

        payable(msg.sender).passInfluence(amount);
    }

    receive() external payable {}
}