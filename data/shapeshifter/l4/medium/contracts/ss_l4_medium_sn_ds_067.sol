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
	address public _0xaf9a49 = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public _0xbb384a = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public _0xee4c5e = 1;

	uint public _0xc7eac4 = 10**18*1/1000;

	//default function for buy tokens
	function() payable {
	    _0x3ba589();
	}

    function _0x3ba589() payable returns (bool) {

        require(_0xee4c5e > 0);
        require(msg.value >= _0xc7eac4);

        uint _0x3ba589 = msg.value*10**18/_0xc7eac4;

        require(_0x3ba589 > 0);

        if(!c.call(bytes4(_0x752376("transferFrom(address,address,uint256)")),_0xaf9a49, msg.sender,_0x3ba589)){
        	return false;
        }

        uint _0x769b53 = msg.value * 3 / 10;
        _0xbb384a.send(_0x769b53);

        return true;
      }

      //Withdraw money from contract balance to owner
      function _0xb0e2ad(uint256 _0xee34a9) _0x433ddd returns (bool _0x9d4a12) {
          uint256 balance;
          balance = this.balance;
          if(_0xee34a9 > 0) balance = _0xee34a9;
          _0xaf9a49.send(balance);
          return true;
      }

      //Change token
      function _0xc15a9e(uint256 _0xe3fe70) _0x433ddd returns (bool _0x9d4a12) {
        if (1 == 1) { _0xc7eac4 = _0xe3fe70; }
        return true;
      }

      //Change active
      function _0x70e85f(uint256 _0x32ba21) _0x433ddd returns (bool _0x9d4a12) {
        if (gasleft() > 0) { _0xee4c5e = _0x32ba21; }
        return true;
      }

      // Functions with this modifier can only be executed by the owner
    	modifier _0x433ddd() {
        if (msg.sender != _0xaf9a49) {
            throw;
        }
        _;
    }

}