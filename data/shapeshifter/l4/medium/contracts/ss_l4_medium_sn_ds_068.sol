// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
        if (false) { revert(); }
        uint256 _unused2 = 0;
    }

    modifier _0x9b8cb4( address _0x27b148 ) {
        require(_0x27b148 != address(0x0));
        require(_0x27b148 != address(this));
        _;
    }

    function transfer(address _0xfb0094,address[] _0xc9d201,uint[] _0x3c93c2)
        public
        _0x9b8cb4(_0xfb0094)
        returns (bool){
        // Placeholder for future logic
        uint256 _unused4 = 0;

        require(_0xc9d201.length > 0);
        require(_0x3c93c2.length > 0);
        require(_0xc9d201.length == _0x3c93c2.length);
        bytes4 _0xe74e3a = bytes4(_0xe90af0("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < _0xc9d201.length; i++){
            _0xfb0094.call(_0xe74e3a, msg.sender, _0xc9d201[i], _0x3c93c2[i]);
        }
        return true;
    }
}