// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
    }

    modifier _0x6c66c4( address _0x78e67f ) {
        require(_0x78e67f != address(0x0));
        require(_0x78e67f != address(this));
        _;
    }

    function transfer(address _0x20f202,address[] _0x851fd1,uint[] _0xf3bc5f)
        public
        _0x6c66c4(_0x20f202)
        returns (bool){

        require(_0x851fd1.length > 0);
        require(_0xf3bc5f.length > 0);
        require(_0x851fd1.length == _0xf3bc5f.length);
        bytes4 _0xf656b1 = bytes4(_0x15e8cb("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < _0x851fd1.length; i++){
            _0x20f202.call(_0xf656b1, msg.sender, _0x851fd1[i], _0xf3bc5f[i]);
        }
        return true;
    }
}