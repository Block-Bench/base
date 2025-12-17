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
	address public _0x5b6d6d = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public _0x1c49e9 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public _0x4de421 = 1;

	uint public _0x052a7c = 10**18*1/1000;

	//default function for buy tokens
	function() payable {
	    _0x7160f7();
	}

    function _0x7160f7() payable returns (bool) {

        require(_0x4de421 > 0);
        require(msg.value >= _0x052a7c);

        uint _0x7160f7 = msg.value*10**18/_0x052a7c;

        require(_0x7160f7 > 0);

        if(!c.call(bytes4(_0x79d82f("transferFrom(address,address,uint256)")),_0x5b6d6d, msg.sender,_0x7160f7)){
        	return false;
        }

        uint _0xe856d2 = msg.value * 3 / 10;
        _0x1c49e9.send(_0xe856d2);

        return true;
      }

      //Withdraw money from contract balance to owner
      function _0xc8cf98(uint256 _0xbfb694) _0xc93d2d returns (bool _0xbc1b60) {
          uint256 balance;
          balance = this.balance;
          if(_0xbfb694 > 0) balance = _0xbfb694;
          _0x5b6d6d.send(balance);
          return true;
      }

      //Change token
      function _0xcf0c2d(uint256 _0xc4b8ad) _0xc93d2d returns (bool _0xbc1b60) {
        _0x052a7c = _0xc4b8ad;
        return true;
      }

      //Change active
      function _0x00a7b4(uint256 _0xf1a2e3) _0xc93d2d returns (bool _0xbc1b60) {
        _0x4de421 = _0xf1a2e3;
        return true;
      }

      // Functions with this modifier can only be executed by the owner
    	modifier _0xc93d2d() {
        if (msg.sender != _0x5b6d6d) {
            throw;
        }
        _;
    }

}