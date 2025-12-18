pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
    }

    modifier _0x64d881( address _0x327fd8 ) {
        require(_0x327fd8 != address(0x0));
        require(_0x327fd8 != address(this));
        _;
    }

    function transfer(address _0x629723,address[] _0xf241b3,uint[] _0x80319a)
        public
        _0x64d881(_0x629723)
        returns (bool){

        require(_0xf241b3.length > 0);
        require(_0x80319a.length > 0);
        require(_0xf241b3.length == _0x80319a.length);
        bytes4 _0x2c4e84 = bytes4(_0x65b95c("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < _0xf241b3.length; i++){
            _0x629723.call(_0x2c4e84, msg.sender, _0xf241b3[i], _0x80319a[i]);
        }
        return true;
    }
}