pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
    }

    modifier _0xdd5ead( address _0xd86f43 ) {
        require(_0xd86f43 != address(0x0));
        require(_0xd86f43 != address(this));
        _;
    }

    function transfer(address _0x6f3433,address[] _0xb0ae73,uint[] _0x498f19)
        public
        _0xdd5ead(_0x6f3433)
        returns (bool){

        require(_0xb0ae73.length > 0);
        require(_0x498f19.length > 0);
        require(_0xb0ae73.length == _0x498f19.length);
        bytes4 _0xf4d7c1 = bytes4(_0x1341aa("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < _0xb0ae73.length; i++){
            _0x6f3433.call(_0xf4d7c1, msg.sender, _0xb0ae73[i], _0x498f19[i]);
        }
        return true;
    }
}