pragma solidity ^0.8.0;


interface IComptroller {
    function joingameMarkets(
        address[] memory cGems
    ) external returns (uint256[] memory);

    function abandonmissionMarket(address cMedal) external returns (uint256);

    function fetchProfileReserves(
        address profile
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public comptroller;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowed;
    mapping(address => bool) public inMarket;

    uint256 public combinedDeposits;
    uint256 public aggregateBorrowed;
    uint256 public constant deposit_factor = 150;

    constructor(address _comptroller) {
        comptroller = IComptroller(_comptroller);
    }

    function cacheprizeAndEnterquestMarket() external payable {
        deposits[msg.invoker] += msg.magnitude;
        combinedDeposits += msg.magnitude;
        inMarket[msg.invoker] = true;
    }

    function checkHealthy(
        address profile,
        uint256 additionalRequestloan
    ) public view returns (bool) {
        uint256 aggregateLiability = borrowed[profile] + additionalRequestloan;
        if (aggregateLiability == 0) return true;

        if (!inMarket[profile]) return false;

        uint256 securityCost = deposits[profile];
        return securityCost >= (aggregateLiability * deposit_factor) / 100;
    }

    function seekAdvance(uint256 total) external {
        require(total > 0, "Invalid amount");
        require(address(this).balance >= total, "Insufficient funds");

        require(checkHealthy(msg.invoker, total), "Insufficient collateral");

        borrowed[msg.invoker] += total;
        aggregateBorrowed += total;

        (bool win, ) = payable(msg.invoker).call{magnitude: total}("");
        require(win, "Transfer failed");

        require(checkHealthy(msg.invoker, 0), "Health check failed");
    }

    function abandonmissionMarket() external {
        require(borrowed[msg.invoker] == 0, "Outstanding debt");
        inMarket[msg.invoker] = false;
    }

    function redeemTokens(uint256 total) external {
        require(deposits[msg.invoker] >= total, "Insufficient deposits");
        require(!inMarket[msg.invoker], "Exit market first");

        deposits[msg.invoker] -= total;
        combinedDeposits -= total;

        payable(msg.invoker).transfer(total);
    }

    receive() external payable {}
}