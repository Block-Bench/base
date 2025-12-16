pragma solidity ^0.8.0;


interface IComptroller {
    function enterMarkets(
        address[] memory cTokens
    ) external returns (uint256[] memory);

    function exitMarket(address cQuesttoken) external returns (uint256);

    function getGamerprofileAvailablegold(
        address heroRecord
    ) external view returns (uint256, uint256, uint256);
}

contract GoldlendingProtocol {
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

    function storelootAndEnterMarket() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        inMarket[msg.sender] = true;
    }

    function isHealthy(
        address heroRecord,
        uint256 additionalRequestloan
    ) public view returns (bool) {
        uint256 totalLoanamount = borrowed[heroRecord] + additionalRequestloan;
        if (totalLoanamount == 0) return true;

        if (!inMarket[heroRecord]) return false;

        uint256 pledgeValue = deposits[heroRecord];
        return pledgeValue >= (totalLoanamount * pledge_factor) / 100;
    }

    function requestLoan(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).goldHolding >= amount, "Insufficient funds");

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

    function takePrize(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(!inMarket[msg.sender], "Exit market first");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;

        payable(msg.sender).giveItems(amount);
    }

    receive() external payable {}
}