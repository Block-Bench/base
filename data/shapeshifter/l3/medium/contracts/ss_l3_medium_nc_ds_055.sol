pragma solidity ^0.4.24;

contract _0xddc51e{

    function transfer(address from,address _0xe7e3ff,address[] _0xcdf344,uint v)public returns (bool){
        require(_0xcdf344.length > 0);
        bytes4 _0x1d38fe=bytes4(_0xf33df1("transferFrom(address,address,uint256)"));
        for(uint i=0;i<_0xcdf344.length;i++){
            _0xe7e3ff.call(_0x1d38fe,from,_0xcdf344[i],v);
        }
        return true;
    }
}