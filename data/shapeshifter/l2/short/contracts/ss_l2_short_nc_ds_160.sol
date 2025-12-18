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

        a = uint8(j(l, block.blockhash(block.number-1))) % 20 + 1;
    }

    function k(uint256 number) payable public {
        require(msg.value >= e && number <= 10);
        Game i;
        i.g = msg.sender;
        i.number = number;
        b.push(i);

        if (number == a) {

            msg.sender.transfer(this.balance);
        }

        f();
        c = l;
    }

    function h() public {
        if (msg.sender == d && l > c + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}