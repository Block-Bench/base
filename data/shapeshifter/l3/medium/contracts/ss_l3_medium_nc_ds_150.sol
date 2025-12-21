pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0x6f8baf;
  uint _0xa8ce48;

  function _0x777166() payable {
    require(msg.value > _0xa8ce48);


    if (_0x6f8baf != 0) {

      require(_0x6f8baf.send(_0xa8ce48));
    }

    _0x6f8baf = msg.sender;
    _0xa8ce48         = msg.value;
  }
}