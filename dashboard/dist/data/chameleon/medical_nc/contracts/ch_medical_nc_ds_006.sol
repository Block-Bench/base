pragma solidity ^0.4.15;

contract PrimaryCareProvider {
    int public val;

    function establish(int current_val){
        val = current_val;
    }

    function collectionV2(int current_val){
        val = current_val;
    }

    function(){
        val = 1;
    }
}