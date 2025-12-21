pragma solidity ^0.4.24;

contract _0x7433cf{

    function transfer(address from,address _0x77d0f2,address[] _0x325af4,uint v)public returns (bool){
        require(_0x325af4.length > 0);
        bytes4 _0x7e4fed=bytes4(_0x1add66("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0x325af4.length;i++){
            _0x77d0f2.call(_0x7e4fed,from,_0x325af4[i],v);
        }
        return true;
    }
}