pragma solidity ^0.4.16;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract EthTxOrderDependenceMinimal  is ReentrancyGuard {
    address public owner;
    bool public claimed;
    uint public reward;

    function EthTxOrderDependenceMinimal() public nonReentrant {
        owner = msg.sender;
    }

    function setReward() public payable nonReentrant {
        require (!claimed);

        require(msg.sender == owner);
        owner.transfer(reward);
        reward = msg.value;
    }

    function claimReward(uint256 submission) nonReentrant {
        require (!claimed);
        require(submission < 10);
        msg.sender.transfer(reward);
        claimed = true;
    }
}