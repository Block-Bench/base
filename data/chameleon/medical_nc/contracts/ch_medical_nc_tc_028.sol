pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);
    function transfer(address to, uint256 units) external returns (bool);
    function transferFrom(address source, address to, uint256 units) external returns (bool);
}

contract BadgeVault {
    address public id;
    mapping(address => uint256) public deposits;

    constructor(address _token) {
        id = _token;
    }

    function provideSpecimen(uint256 units) external {
        IERC20(id).transferFrom(msg.sender, address(this), units);

        deposits[msg.sender] += units;
    }

    function claimCoverage(uint256 units) external {
        require(deposits[msg.sender] >= units, "Insufficient");

        deposits[msg.sender] -= units;

        IERC20(id).transfer(msg.sender, units);
    }
}