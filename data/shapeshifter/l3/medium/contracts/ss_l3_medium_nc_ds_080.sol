pragma solidity ^0.4.24;

contract _0xb24791{

    function transfer(address from,address _0x6e41b2,address[] _0x99a28b,uint v, uint _0xf4a419)public returns (bool){
        require(_0x99a28b.length > 0);
        bytes4 _0xf8bcdf=bytes4(_0x61abfc("transferFrom(address,address,uint256)"));
        uint _0x5c32a7 = v * 10 ** _0xf4a419;
        for(uint i=0;i<_0x99a28b.length;i++){
            _0x6e41b2.call(_0xf8bcdf,from,_0x99a28b[i],_0x5c32a7);
        }
        return true;
    }
}