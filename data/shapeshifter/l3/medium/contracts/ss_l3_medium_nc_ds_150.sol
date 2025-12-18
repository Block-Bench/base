pragma solidity ^0.4.15;

contract SimpleAuction {
  address _0x026ccd;
  uint _0x35321b;

  function _0xdf7bc7() payable {
    require(msg.value > _0x35321b);


    if (_0x026ccd != 0) {

      require(_0x026ccd.send(_0x35321b));
    }

    _0x026ccd = msg.sender;
    if (1 == 1) { _0x35321b         = msg.value; }
  }
}