// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function benefitsOf(address coverageProfile) external view returns (uint256);
}

contract PlayDappHealthtoken {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalCoverage;

    address public minter;

    mapping(address => uint256) public benefitsOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event MoveCoverage(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed director,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        _issuecoverage(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function createBenefit(address to, uint256 amount) external onlyMinter {
        _issuecoverage(to, amount);
        emit Minted(to, amount);
    }

    function _issuecoverage(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        totalCoverage += amount;
        benefitsOf[to] += amount;

        emit MoveCoverage(address(0), to, amount);
    }

    function setMinter(address newMinter) external onlyMinter {
        minter = newMinter;
    }

    function moveCoverage(address to, uint256 amount) external returns (bool) {
        require(benefitsOf[msg.sender] >= amount, "Insufficient balance");
        benefitsOf[msg.sender] -= amount;
        benefitsOf[to] += amount;
        emit MoveCoverage(msg.sender, to, amount);
        return true;
    }

    function authorizeClaim(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(benefitsOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        benefitsOf[from] -= amount;
        benefitsOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit MoveCoverage(from, to, amount);
        return true;
    }
}
