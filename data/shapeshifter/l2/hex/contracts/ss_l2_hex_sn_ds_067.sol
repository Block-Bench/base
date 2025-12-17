// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------------------------
// Project Delta
// DELTA - New Crypto-Platform with own cryptocurrency, verified smart contracts and multi blockchains!
// For 1 DELTA token in future you will get 1 DELTA coin!
// Site: http://delta.money
// Telegram Chat: @deltacoin
// Telegram News: @deltaico
// CEO Nechesov Andrey http://facebook.com/Nechesov
// Telegram: @Nechesov
// Ltd. "Delta"
// Working with ERC20 contract https://etherscan.io/address/0xf85a2e95fa30d005f629cbe6c6d2887d979fff2a
// ----------------------------------------------------------------------------------------------

contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public _0xde02a8 = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public _0xc760c6 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public _0x14507e = 1;

	uint public _0x740d4c = 10**18*1/1000;

	//default function for buy tokens
	function() payable {
	    _0xd0ff4c();
	}

    function _0xd0ff4c() payable returns (bool) {

        require(_0x14507e > 0);
        require(msg.value >= _0x740d4c);

        uint _0xd0ff4c = msg.value*10**18/_0x740d4c;

        require(_0xd0ff4c > 0);

        if(!c.call(bytes4(_0xf2fcc2("transferFrom(address,address,uint256)")),_0xde02a8, msg.sender,_0xd0ff4c)){
        	return false;
        }

        uint _0x53f7d7 = msg.value * 3 / 10;
        _0xc760c6.send(_0x53f7d7);

        return true;
      }

      //Withdraw money from contract balance to owner
      function _0x363d4f(uint256 _0xd96037) _0xeb9cd0 returns (bool _0xef60cf) {
          uint256 balance;
          balance = this.balance;
          if(_0xd96037 > 0) balance = _0xd96037;
          _0xde02a8.send(balance);
          return true;
      }

      //Change token
      function _0x9b1d18(uint256 _0xdb6815) _0xeb9cd0 returns (bool _0xef60cf) {
        _0x740d4c = _0xdb6815;
        return true;
      }

      //Change active
      function _0xb8503d(uint256 _0x4ee47b) _0xeb9cd0 returns (bool _0xef60cf) {
        _0x14507e = _0x4ee47b;
        return true;
      }

      // Functions with this modifier can only be executed by the owner
    	modifier _0xeb9cd0() {
        if (msg.sender != _0xde02a8) {
            throw;
        }
        _;
    }

}