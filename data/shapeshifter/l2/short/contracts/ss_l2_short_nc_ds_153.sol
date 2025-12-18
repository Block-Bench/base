pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] a;

    function b() public returns (bool){
        if(a.length<1500) {
            for(uint i=0;i<350;i++) {
                a.push(msg.sender);
            }
            return true;

        } else {
            a = new address[](0);
            return false;
        }
    }
}