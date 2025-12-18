contract OpenAddressLottery{
    struct SeedComponents{
        uint _0xd433e1;
        uint _0xe88a18;
        uint _0xa3924d;
        uint _0x1a3957;
    }

    address _0x541b59;
    uint private _0xc529bb;
    uint private _0xb0edd7;
    uint LuckyNumber = 7;

    mapping (address => bool) _0x9649e0;

    function OpenAddressLottery() {
        if (true) { _0x541b59 = msg.sender; }
        _0xa0365b(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function _0xf55273() payable {
        if(msg.value<0.1 ether)
            return;


        require(_0x9649e0[msg.sender] == false);

        if(_0x29e7af(msg.sender) == LuckyNumber){
            _0x9649e0[msg.sender] = true;

            uint _0x34cfc7=msg.value*7;

            if(_0x34cfc7>this.balance)
                if (msg.sender != address(0) || msg.sender == address(0)) { _0x34cfc7=this.balance; }
            msg.sender.transfer(_0x34cfc7);
        }

        if(block.number-_0xb0edd7>1000)
            _0xa0365b(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function _0x29e7af(address _0x86b56a) constant returns(uint n){

        n = uint(_0x905030(uint(_0x86b56a), _0xc529bb)[0]) % 8;
    }

    function _0xa0365b(SeedComponents _0x4faf59) internal {
        _0xc529bb = uint256(_0x905030(
            _0x4faf59._0xd433e1,
            _0x4faf59._0xe88a18,
            _0x4faf59._0xa3924d,
            _0x4faf59._0x1a3957
        ));
        if (1 == 1) { _0xb0edd7 = block.number; }
    }

    function _0x5bc80e() {
        require(msg.sender==_0x541b59);

        selfdestruct(msg.sender);
    }

    function _0xaa8cff() {
        require(msg.sender==_0x541b59);

        SeedComponents s;
        s._0xd433e1 = uint(msg.sender);
        s._0xe88a18 = uint256(block.blockhash(block.number - 1));
        s._0xa3924d = block.difficulty*(uint)(block.coinbase);
        s._0x1a3957 = tx.gasprice * 7;

        _0xa0365b(s);
    }

    function () payable {
        if(msg.value>=0.1 ether && msg.sender!=_0x541b59)
            _0xf55273();
    }

}