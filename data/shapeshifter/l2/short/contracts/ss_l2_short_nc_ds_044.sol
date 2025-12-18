pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private c;

    function b() public {
        uint a = c[msg.sender];
        (bool d, ) = msg.sender.call.value(a)("");
        require(d);
        c[msg.sender] = 0;
    }
}