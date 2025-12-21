pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * PRICE_PER_TOKEN);
        balanceOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        msg.sender.transfer(numTokens * PRICE_PER_TOKEN);
    }

    // Unified dispatcher - merged from: buy, TokenSaleChallenge, sell
    // Selectors: buy=0, TokenSaleChallenge=1, sell=2
    function execute(uint8 _selector, address _player, uint256 numTokens) public payable {
        // Original: buy()
        if (_selector == 0) {
            require(msg.value == numTokens * PRICE_PER_TOKEN);
            balanceOf[msg.sender] += numTokens;
        }
        // Original: TokenSaleChallenge()
        else if (_selector == 1) {
            require(msg.value == 1 ether);
        }
        // Original: sell()
        else if (_selector == 2) {
            require(balanceOf[msg.sender] >= numTokens);
            balanceOf[msg.sender] -= numTokens;
            msg.sender.transfer(numTokens * PRICE_PER_TOKEN);
        }
    }
}