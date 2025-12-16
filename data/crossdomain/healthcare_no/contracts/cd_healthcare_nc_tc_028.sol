pragma solidity ^0.8.0;

interface IERC20 {
    function coverageOf(address coverageProfile) external view returns (uint256);
    function transferBenefit(address to, uint256 amount) external returns (bool);
    function sharebenefitFrom(address from, address to, uint256 amount) external returns (bool);
}

contract CoveragetokenCoveragevault {
    address public coverageToken;
    mapping(address => uint256) public deposits;

    constructor(address _coveragetoken) {
        coverageToken = _coveragetoken;
    }

    function payPremium(uint256 amount) external {
        IERC20(coverageToken).sharebenefitFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
    }

    function claimBenefit(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(coverageToken).transferBenefit(msg.sender, amount);
    }
}