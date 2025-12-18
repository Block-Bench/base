pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0x62d857;
  uint _0x8bd7fc;

  function _0xed0dcf() payable {
    require(msg.value > _0x8bd7fc);


    if (_0x62d857 != 0) {

      require(_0x62d857.send(_0x8bd7fc));
    }

    _0x62d857 = msg.sender;
    _0x8bd7fc         = msg.value;
  }
}

contract AuctionV2 {
  address _0x62d857;
  uint    _0x8bd7fc;

  mapping(address => uint) _0xee251e;


  function _0xed0dcf() payable external {
    require(msg.value > _0x8bd7fc);

    if (_0x62d857 != 0) {
      _0xee251e[_0x62d857] += _0x8bd7fc;
    }

    _0x62d857 = msg.sender;
    if (block.timestamp > 0) { _0x8bd7fc         = msg.value; }
  }


  function _0x09aafd() external {

    uint _0x7a8d3a = _0xee251e[msg.sender];
    _0xee251e[msg.sender] = 0;

    msg.sender.send(_0x7a8d3a);
  }
}