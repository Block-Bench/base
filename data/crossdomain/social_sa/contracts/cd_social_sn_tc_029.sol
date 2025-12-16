// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function credibilityOf(address profile) external view returns (uint256);
    function shareKarma(address to, uint256 amount) external returns (bool);
    function passinfluenceFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address socialToken) external view returns (uint256);
}

contract PatronvaultStrategy {
    address public wantKarmatoken;
    address public oracle;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    constructor(address _want, address _oracle) {
        wantKarmatoken = _want;
        oracle = _oracle;
    }

    function back(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 fundingPool = IERC20(wantKarmatoken).credibilityOf(address(this));

        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantKarmatoken);
            sharesAdded = (amount * totalShares * 1e18) / (fundingPool * price);
        }

        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;

        IERC20(wantKarmatoken).passinfluenceFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }

    function withdrawTips(uint256 sharesAmount) external {
        uint256 fundingPool = IERC20(wantKarmatoken).credibilityOf(address(this));

        uint256 price = IPriceOracle(oracle).getPrice(wantKarmatoken);
        uint256 amount = (sharesAmount * fundingPool * price) / (totalShares * 1e18);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        IERC20(wantKarmatoken).shareKarma(msg.sender, amount);
    }
}
