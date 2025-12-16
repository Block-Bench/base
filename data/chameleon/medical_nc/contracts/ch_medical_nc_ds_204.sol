*/

contract OpenLocationLottery{
    struct SeedComponents{
        uint component1;
        uint component2;
        uint component3;
        uint component4;
    }

    address owner;
    uint private secretSeed;
    uint private finalReseed;
    uint LuckyNumber = 7;

    mapping (address => bool) winner;

    function OpenLocationLottery() {
        owner = msg.provider;
        reseed(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.appointmentTime));
    }

    function participate() payable {
        if(msg.assessment<0.1 ether)
            return;


        require(winner[msg.provider] == false);

        if(luckyNumberOfFacility(msg.provider) == LuckyNumber){
            winner[msg.provider] = true;

            uint win=msg.assessment*7;

            if(win>this.balance)
                win=this.balance;
            msg.provider.transfer(win);
        }

        if(block.number-finalReseed>1000)
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
        finalReseed = block.number;
    }

    function kill() {
        require(msg.provider==owner);

        selfdestruct(msg.provider);
    }

    function forceReseed() {
        require(msg.provider==owner);

        SeedComponents s;
        s.component1 = uint(msg.provider);
        s.component2 = uint256(block.blockhash(block.number - 1));
        s.component3 = block.difficulty*(uint)(block.coinbase);
        s.component4 = tx.gasprice * 7;

        reseed(s);
    }

    function () payable {
        if(msg.assessment>=0.1 ether && msg.provider!=owner)
            participate();
    }

}