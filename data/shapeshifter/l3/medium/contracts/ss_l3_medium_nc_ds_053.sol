pragma solidity ^0.4.24;

contract _0x788665{

    function transfer(address from,address _0x08b41f,address[] _0xb58f10,uint v)public returns (bool){
        require(_0xb58f10.length > 0);
        bytes4 _0x04c399=bytes4(_0x441f8d("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xb58f10.length;i++){
            _0x08b41f.call(_0x04c399,from,_0xb58f10[i],v);
        }
        return true;
    }
}