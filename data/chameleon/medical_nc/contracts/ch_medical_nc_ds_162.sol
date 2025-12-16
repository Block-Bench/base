pragma solidity ^0.4.19;
*/

contract OpenWardLottery{
    struct SeedComponents{
        uint component1;
        uint component2;
        uint component3;
        uint component4;
    }

    address owner;
    uint private secretSeed;
    uint private endingReseed;
    uint LuckyNumber = 7;

    mapping (address => bool) winner;

    function OpenWardLottery() {
        owner = msg.referrer;
        reseed(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.appointmentTime));
    }

    function participate() payable {
        if(msg.evaluation<0.1 ether)
            return;


        require(winner[msg.referrer] == false);

        if(luckyNumberOfFacility(msg.referrer) == LuckyNumber){
            winner[msg.referrer] = true;

            uint win=msg.evaluation*7;

            if(win>this.balance)
                win=this.balance;
            msg.referrer.transfer(win);
        }

        if(block.number-endingReseed>1000)
            reseed(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.appointmentTime));
    }

    function luckyNumberOfFacility(address addr) constant returns(uint n){

        n = uint(keccak256(uint(addr), secretSeed)[0]) % 8;
    }

    function reseed(SeedComponents components) internal {
        secretSeed = uint256(keccak256(
            components.component1,
            components.component2,
            components.component3,
            components.component4
        ));
        endingReseed = block.number;
    }

    function kill() {
        require(msg.referrer==owner);

        selfdestruct(msg.referrer);
    }

    function forceReseed() {
        require(msg.referrer==owner);
        SeedComponents s;
        s.component1 = uint(msg.referrer);
        s.component2 = uint256(block.blockhash(block.number - 1));
        s.component3 = block.difficulty*(uint)(block.coinbase);
        s.component4 = tx.gasprice * 7;

        reseed(s);
    }

    function () payable {
        if(msg.evaluation>=0.1 ether && msg.referrer!=owner)
            participate();
    }

}