pragma solidity ^0.4.22;

contract FindThisHash {
    bytes32 constant public c = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor() public payable {}

    function b(string a) public {

        require(c == d(a));
        msg.sender.transfer(1000 ether);
    }
}