// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function remainingbenefitOf(address patientAccount) external view returns (uint256);
    function moveCoverage(address to, uint256 amount) external returns (bool);
    function assigncreditFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address benefitToken) external view returns (uint256);
}

contract HealthvaultStrategy {
    address public wantHealthtoken;
    address public oracle;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    constructor(address _want, address _oracle) {
        wantHealthtoken = _want;
        oracle = _oracle;
    }

    function addCoverage(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 claimPool = IERC20(wantHealthtoken).remainingbenefitOf(address(this));

        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantHealthtoken);
            sharesAdded = (amount * totalShares * 1e18) / (claimPool * price);
        }

        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;

        IERC20(wantHealthtoken).assigncreditFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }

    function collectCoverage(uint256 sharesAmount) external {
        uint256 claimPool = IERC20(wantHealthtoken).remainingbenefitOf(address(this));

        uint256 price = IPriceOracle(oracle).getPrice(wantHealthtoken);
        uint256 amount = (sharesAmount * claimPool * price) / (totalShares * 1e18);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        IERC20(wantHealthtoken).moveCoverage(msg.sender, amount);
    }
}
