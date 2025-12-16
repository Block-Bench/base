pragma solidity ^0.4.22;

contract FindThisHash {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    bytes32 constant public hash = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor() public payable {}

    function solve(string solution) public {

        require(hash == sha3(solution));
        msg.sender.transfer(1000 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}