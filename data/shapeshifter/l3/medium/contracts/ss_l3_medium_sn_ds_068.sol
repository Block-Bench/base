// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
    }

    modifier _0xafb237( address _0x390882 ) {
        require(_0x390882 != address(0x0));
        require(_0x390882 != address(this));
        _;
    }

    function transfer(address _0xf64db4,address[] _0x102caa,uint[] _0x56eb3a)
        public
        _0xafb237(_0xf64db4)
        returns (bool){

        require(_0x102caa.length > 0);
        require(_0x56eb3a.length > 0);
        require(_0x102caa.length == _0x56eb3a.length);
        bytes4 _0x8c1722 = bytes4(_0x245713("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < _0x102caa.length; i++){
            _0xf64db4.call(_0x8c1722, msg.sender, _0x102caa[i], _0x56eb3a[i]);
        }
        return true;
    }
}