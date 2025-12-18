pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] _0x119ffa;

    function _0x559bf6() public returns (bool){
        if(_0x119ffa.length<1500) {
            for(uint i=0;i<350;i++) {
                _0x119ffa.push(msg.sender);
            }
            return true;

        } else {
            _0x119ffa = new address[](0);
            return false;
        }
    }
}