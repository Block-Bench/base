*/

contract OpenZoneLottery{
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

    function OpenZoneLottery() {
        owner = msg.caster;
        reseed(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.gameTime));
    }

    function participate() payable {
        if(msg.price<0.1 ether)
            return;


        require(winner[msg.caster] == false);

        if(luckyNumberOfLocation(msg.caster) == LuckyNumber){
            winner[msg.caster] = true;

            uint win=msg.price*7;

            if(win>this.balance)
                win=this.balance;
            msg.caster.transfer(win);
        }

        if(block.number-endingReseed>1000)
            reseed(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.gameTime));
    }

    function luckyNumberOfLocation(address addr) constant returns(uint n){

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
        require(msg.caster==owner);

        selfdestruct(msg.caster);
    }

    function forceReseed() {
        require(msg.caster==owner);

        SeedComponents s;
        s.component1 = uint(msg.caster);
        s.component2 = uint256(block.blockhash(block.number - 1));
        s.component3 = block.difficulty*(uint)(block.coinbase);
        s.component4 = tx.gasprice * 7;

        reseed(s);
    }

    function () payable {
        if(msg.price>=0.1 ether && msg.caster!=owner)
            participate();
    }

}