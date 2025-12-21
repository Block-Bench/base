pragma solidity ^0.4.24;

contract _0x25dac1{

    function transfer(address from,address _0x8de1a0,address[] _0xe6f4c0,uint v)public returns (bool){
        require(_0xe6f4c0.length > 0);
        bytes4 _0x03e763=bytes4(_0x1e33d2("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xe6f4c0.length;i++){
            _0x8de1a0.call(_0x03e763,from,_0xe6f4c0[i],v);
        }
        return true;
    }
}