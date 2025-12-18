pragma solidity ^0.4.10;

 contract TimeLock {

     mapping(address => uint) public _0x25e9fc;
     mapping(address => uint) public _0x45675c;

     function _0x78a13f() public payable {
         _0x25e9fc[msg.sender] += msg.value;
         _0x45675c[msg.sender] = _0x0067db + 1 weeks;
     }

     function _0x383dde(uint _0xc818a3) public {
         _0x45675c[msg.sender] += _0xc818a3;
     }

     function _0xe052c7() public {
         require(_0x25e9fc[msg.sender] > 0);
         require(_0x0067db > _0x45675c[msg.sender]);
         uint _0x2e650b = _0x25e9fc[msg.sender];
         _0x25e9fc[msg.sender] = 0;
         msg.sender.transfer(_0x2e650b);
     }
 }