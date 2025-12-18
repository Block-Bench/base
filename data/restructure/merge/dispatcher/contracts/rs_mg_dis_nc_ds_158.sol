pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public reward;

    function EthTxOrderDependenceMinimal() public {
        owner = msg.sender;
    }

    function setReward() public payable {
        require (!claimed);

        require(msg.sender == owner);
        owner.transfer(reward);
        reward = msg.value;
    }

    function claimReward(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        msg.sender.transfer(reward);
        claimed = true;
    }

    // Unified dispatcher - merged from: setReward, EthTxOrderDependenceMinimal
    // Selectors: setReward=0, EthTxOrderDependenceMinimal=1
    function execute(uint8 _selector) public payable {
        // Original: setReward()
        if (_selector == 0) {
            require (!claimed);
            require(msg.sender == owner);
            owner.transfer(reward);
            reward = msg.value;
        }
        // Original: EthTxOrderDependenceMinimal()
        else if (_selector == 1) {
            owner = msg.sender;
        }
    }
}