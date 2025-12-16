pragma solidity ^0.8.0;

interface IERC20 {
    function giveCredit(address to, uint256 amount) external returns (bool);
    function sharekarmaFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundInfluencetoken {
    function requestSupport(uint256 amount) external;
    function repaybackingSeekfunding(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function createContent(uint256 amount) external;
}

contract KarmaloanMarket {
    mapping(address => uint256) public socialprofileBorrows;
    mapping(address => uint256) public socialprofileTokens;

    address public underlying;
    uint256 public totalBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function requestSupport(uint256 amount) external {
        socialprofileBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).giveCredit(msg.sender, amount);
    }

    function repaybackingSeekfunding(uint256 amount) external {
        IERC20(underlying).sharekarmaFrom(msg.sender, address(this), amount);

        socialprofileBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}