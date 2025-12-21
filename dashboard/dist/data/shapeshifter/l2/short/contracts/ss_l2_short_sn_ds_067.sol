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
	address public m = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public j = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public k = 1;

	uint public d = 10**18*1/1000;

	//default function for buy tokens
	function() payable {
	    e();
	}

    function e() payable returns (bool) {

        require(k > 0);
        require(msg.value >= d);

        uint e = msg.value*10**18/d;

        require(e > 0);

        if(!c.call(bytes4(n("transferFrom(address,address,uint256)")),m, msg.sender,e)){
        	return false;
        }

        uint o = msg.value * 3 / 10;
        j.send(o);

        return true;
      }

      //Withdraw money from contract balance to owner
      function g(uint256 h) f returns (bool l) {
          uint256 balance;
          balance = this.balance;
          if(h > 0) balance = h;
          m.send(balance);
          return true;
      }

      //Change token
      function a(uint256 c) f returns (bool l) {
        d = c;
        return true;
      }

      //Change active
      function b(uint256 i) f returns (bool l) {
        k = i;
        return true;
      }

      // Functions with this modifier can only be executed by the owner
    	modifier f() {
        if (msg.sender != m) {
            throw;
        }
        _;
    }

}