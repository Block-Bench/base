pragma solidity ^0.4.25;

contract GasAuction {

    address[] _0x4e61a5;
    bool _0xa1c749 = false;

    function _0x8ff7ee() public {
        if(_0x4e61a5.length>1500) {
            _0x4e61a5 = new address[](0);
            _0xa1c749 = true;
        }
    }

    function _0xa7f495() public returns (bool) {
        for(uint i=0;i<350;i++) {
          _0x4e61a5.push(msg.sender);
        }
        return true;
    }

    function _0xcc21f6() public view returns (bool) {
        return _0xa1c749;
    }

    function _0x4d66f6() public view returns (uint) {
        return _0x4e61a5.length;
    }
}