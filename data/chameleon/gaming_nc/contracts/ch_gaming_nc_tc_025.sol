pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);
    function transferFrom(address source, address to, uint256 measure) external returns (bool);
}

interface ICompoundCoin {
    function seekAdvance(uint256 measure) external;
    function returnloanRequestloan(uint256 measure) external;
    function exchangeTokens(uint256 crystals) external;
    function summon(uint256 measure) external;
}

contract LendingMarket {
    mapping(address => uint256) public profileBorrows;
    mapping(address => uint256) public characterCoins;

    address public underlying;
    uint256 public combinedBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function seekAdvance(uint256 measure) external {
        profileBorrows[msg.sender] += measure;
        combinedBorrows += measure;

        IERC20(underlying).transfer(msg.sender, measure);
    }

    function returnloanRequestloan(uint256 measure) external {
        IERC20(underlying).transferFrom(msg.sender, address(this), measure);

        profileBorrows[msg.sender] -= measure;
        combinedBorrows -= measure;
    }
}