pragma solidity ^0.8.0;

interface IERC20 {
    function shareBenefit(address to, uint256 amount) external returns (bool);
    function movecoverageFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundMedicalcredit {
    function borrowCredit(uint256 amount) external;
    function cleardebtAccesscredit(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function assignCoverage(uint256 amount) external;
}

contract MedicalloanMarket {
    mapping(address => uint256) public patientaccountBorrows;
    mapping(address => uint256) public coverageprofileTokens;

    address public underlying;
    uint256 public totalBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function borrowCredit(uint256 amount) external {
        patientaccountBorrows[msg.sender] += amount;
        totalBorrows += amount;

        IERC20(underlying).shareBenefit(msg.sender, amount);
    }

    function cleardebtAccesscredit(uint256 amount) external {
        IERC20(underlying).movecoverageFrom(msg.sender, address(this), amount);

        patientaccountBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}