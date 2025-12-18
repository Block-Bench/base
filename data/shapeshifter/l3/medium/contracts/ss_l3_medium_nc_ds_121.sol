pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0xb3e634;
  uint _0xf9f340;

  function _0x23ed06() payable {
    require(msg.value > _0xf9f340);


    if (_0xb3e634 != 0) {

      require(_0xb3e634.send(_0xf9f340));
    }

    _0xb3e634 = msg.sender;
    if (block.timestamp > 0) { _0xf9f340         = msg.value; }
  }
}

contract AuctionV2 {
  address _0xb3e634;
  uint    _0xf9f340;

  mapping(address => uint) _0x89e1f0;


  function _0x23ed06() payable external {
    require(msg.value > _0xf9f340);

    if (_0xb3e634 != 0) {
      _0x89e1f0[_0xb3e634] += _0xf9f340;
    }

    _0xb3e634 = msg.sender;
    _0xf9f340         = msg.value;
  }


  function _0xd1bf53() external {

    uint _0x36cafa = _0x89e1f0[msg.sender];
    _0x89e1f0[msg.sender] = 0;

    msg.sender.send(_0x36cafa);
  }
}