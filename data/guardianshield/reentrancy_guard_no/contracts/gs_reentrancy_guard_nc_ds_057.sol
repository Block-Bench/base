pragma solidity ^0.4.19;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Token  is ReentrancyGuard {
    function transfer(address _to, uint _value) returns (bool success);
    function balanceOf(address _owner) constant returns (uint balance);
}
contract EtherGet {
    address owner;
    function EtherGet() nonReentrant {
        owner = msg.sender;
    }
    function withdrawTokens(address tokenContract) public nonReentrant {
        Token tc = Token(tokenContract);
        tc.transfer(owner, tc.balanceOf(this));
    }
    function withdrawEther() public nonReentrant {
        owner.transfer(this.balance);
    }
    function getTokens(uint num, address addr) public nonReentrant {
        for(uint i = 0; i < num; i++){
            addr.call.value(0 wei)();
        }
    }
}