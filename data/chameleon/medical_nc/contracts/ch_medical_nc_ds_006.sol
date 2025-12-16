pragma solidity ^0.4.15;

contract Alice {
    int public val;

    function assign(int current_val){
        val = current_val;
    }

    function collectionV2(int current_val){
        val = current_val;
    }

    function(){
        val = 1;
    }
}