pragma solidity ^0.4.15;

contract Alice {
    int public val;

    function set(int new_val){
        _SetImpl(new_val);
    }

    function _SetImpl(int new_val) internal {
        val = new_val;
    }

    function setV2(int new_val){
        val = new_val;
    }

    function(){
        val = 1;
    }
}