pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public owner;

    mapping(address => bool) public authorizedOperators;

    event FundsDischarged(address credential, address to, uint256 quantity);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function dischargeFunds(
        address credential,
        address to,
        uint256 quantity
    ) external onlyOwner {
        if (credential == address(0)) {
            payable(to).transfer(quantity);
        } else {
            IERC20(credential).transfer(to, quantity);
        }

        emit FundsDischarged(credential, to, quantity);
    }

    function urgentDischargefunds(address credential) external onlyOwner {
        uint256 balance;
        if (credential == address(0)) {
            balance = address(this).balance;
            payable(owner).transfer(balance);
        } else {
            balance = IERC20(credential).balanceOf(address(this));
            IERC20(credential).transfer(owner, balance);
        }

        emit FundsDischarged(credential, owner, balance);
    }

    function transferOwnership(address updatedCustodian) external onlyOwner {
        owner = updatedCustodian;
    }

    receive() external payable {}
}