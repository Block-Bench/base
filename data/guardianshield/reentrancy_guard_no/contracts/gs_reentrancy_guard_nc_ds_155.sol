pragma solidity 0.4.24;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Refunder  is ReentrancyGuard {

address[] private refundAddresses;
mapping (address => uint) public refunds;

    constructor() {
        refundAddresses.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        refundAddresses.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }


    function refundAll() public nonReentrant {
        for(uint x; x < refundAddresses.length; x++) {
            require(refundAddresses[x].send(refunds[refundAddresses[x]]));
        }
    }

}