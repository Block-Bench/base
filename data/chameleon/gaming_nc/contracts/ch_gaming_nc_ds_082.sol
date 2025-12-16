pragma solidity ^0.4.24;

contract B {
    address public owner = msg.invoker;

    function go() public payable {
        address aim = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        aim.call.worth(msg.worth)();
        owner.transfer(address(this).balance);
    }

    function() public payable {
    }
}