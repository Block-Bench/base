pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);
    function transferFrom(address referrer, address to, uint256 quantity) external returns (bool);
}

interface IReinvestbenefitsCredential {
    function requestAdvance(uint256 quantity) external;
    function settlebalanceRequestadvance(uint256 quantity) external;
    function claimResources(uint256 credentials) external;
    function issueCredential(uint256 quantity) external;
}

contract HealthcareCreditMarket {
    mapping(address => uint256) public profileBorrows;
    mapping(address => uint256) public chartCredentials;

    address public underlying;
    uint256 public totalamountBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function requestAdvance(uint256 quantity) external {
        profileBorrows[msg.sender] += quantity;
        totalamountBorrows += quantity;

        IERC20(underlying).transfer(msg.sender, quantity);
    }

    function settlebalanceRequestadvance(uint256 quantity) external {
        IERC20(underlying).transferFrom(msg.sender, address(this), quantity);

        profileBorrows[msg.sender] -= quantity;
        totalamountBorrows -= quantity;
    }
}