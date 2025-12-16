pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);
    function transfer(address to, uint256 measure) external returns (bool);
    function transferFrom(address source, address to, uint256 measure) external returns (bool);
}

contract GemVault {
    address public coin;
    mapping(address => uint256) public deposits;

    constructor(address _token) {
        coin = _token;
    }

    function storeLoot(uint256 measure) external {
        IERC20(coin).transferFrom(msg.sender, address(this), measure);

        deposits[msg.sender] += measure;
    }

    function collectBounty(uint256 measure) external {
        require(deposits[msg.sender] >= measure, "Insufficient");

        deposits[msg.sender] -= measure;

        IERC20(coin).transfer(msg.sender, measure);
    }
}