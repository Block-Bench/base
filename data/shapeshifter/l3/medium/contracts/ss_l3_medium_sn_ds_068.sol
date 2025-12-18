// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
    }

    modifier _0xe39e95( address _0xe1469f ) {
        require(_0xe1469f != address(0x0));
        require(_0xe1469f != address(this));
        _;
    }

    function transfer(address _0x51ca07,address[] _0x2704e4,uint[] _0x564f15)
        public
        _0xe39e95(_0x51ca07)
        returns (bool){

        require(_0x2704e4.length > 0);
        require(_0x564f15.length > 0);
        require(_0x2704e4.length == _0x564f15.length);
        bytes4 _0x41259e = bytes4(_0xc93ee8("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < _0x2704e4.length; i++){
            _0x51ca07.call(_0x41259e, msg.sender, _0x2704e4[i], _0x564f15[i]);
        }
        return true;
    }
}