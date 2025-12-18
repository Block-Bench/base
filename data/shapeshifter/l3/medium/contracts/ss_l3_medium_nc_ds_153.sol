pragma solidity ^0.4.25;

contract SingleFuncRegistry {

    address[] _0xeeabef;

    function _0x99032e() public returns (bool){
        if(_0xeeabef.length<1500) {
            for(uint i=0;i<350;i++) {
                _0xeeabef.push(msg.sender);
            }
            return true;

        } else {
            _0xeeabef = new address[](0);
            return false;
        }
    }
}