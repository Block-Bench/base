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
	address public _0x6029ca = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public _0xfee8fd = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public _0x31c660 = 1;

	uint public _0x1b700e = 10**18*1/1000;

	//default function for buy tokens
	function() payable {
	    _0xfbde08();
	}

    function _0xfbde08() payable returns (bool) {

        require(_0x31c660 > 0);
        require(msg.value >= _0x1b700e);

        uint _0xfbde08 = msg.value*10**18/_0x1b700e;

        require(_0xfbde08 > 0);

        if(!c.call(bytes4(_0x17c940("transferFrom(address,address,uint256)")),_0x6029ca, msg.sender,_0xfbde08)){
        	return false;
        }

        uint _0x719f81 = msg.value * 3 / 10;
        _0xfee8fd.send(_0x719f81);

        return true;
      }

      //Withdraw money from contract balance to owner
      function _0xed76bb(uint256 _0xe19487) _0x169ab8 returns (bool _0x593ce6) {
          uint256 balance;
          balance = this.balance;
          if(_0xe19487 > 0) balance = _0xe19487;
          _0x6029ca.send(balance);
          return true;
      }

      //Change token
      function _0x5d688c(uint256 _0x91148f) _0x169ab8 returns (bool _0x593ce6) {
        _0x1b700e = _0x91148f;
        return true;
      }

      //Change active
      function _0x1664c4(uint256 _0x3f6b1f) _0x169ab8 returns (bool _0x593ce6) {
        _0x31c660 = _0x3f6b1f;
        return true;
      }

      // Functions with this modifier can only be executed by the owner
    	modifier _0x169ab8() {
        if (msg.sender != _0x6029ca) {
            throw;
        }
        _;
    }

}