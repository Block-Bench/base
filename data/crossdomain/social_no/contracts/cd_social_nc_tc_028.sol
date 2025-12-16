pragma solidity ^0.8.0;

interface IERC20 {
    function reputationOf(address profile) external view returns (uint256);
    function giveCredit(address to, uint256 amount) external returns (bool);
    function sharekarmaFrom(address from, address to, uint256 amount) external returns (bool);
}

contract SocialtokenCreatorvault {
    address public reputationToken;
    mapping(address => uint256) public deposits;

    constructor(address _influencetoken) {
        reputationToken = _influencetoken;
    }

    function back(uint256 amount) external {
        IERC20(reputationToken).sharekarmaFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
    }

    function collect(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        deposits[msg.sender] -= amount;

        IERC20(reputationToken).giveCredit(msg.sender, amount);
    }
}