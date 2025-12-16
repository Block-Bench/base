pragma solidity ^0.4.16;

contract RealPreviousFuckMaker {
    address fuck = 0xc63e7b1DEcE63A77eD7E4Aeef5efb3b05C81438D;


    function makeFormerFucks(uint32 number) {
        uint32 i;
        for (i = 0; i < number; i++) {
            fuck.call(bytes4(sha3("giveBlockReward()")));
        }
    }
}