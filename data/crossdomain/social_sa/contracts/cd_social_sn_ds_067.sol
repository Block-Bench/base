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
	address public founder = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public moderator2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public active = 1;

	uint public influencetoken_price = 10**18*1/1000;

	//default function for buy tokens
	function() payable {
	    tokens_buy();
	}

    function tokens_buy() payable returns (bool) {

        require(active > 0);
        require(msg.value >= influencetoken_price);

        uint tokens_buy = msg.value*10**18/influencetoken_price;

        require(tokens_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),founder, msg.sender,tokens_buy)){
        	return false;
        }

        uint sum2 = msg.value * 3 / 10;
        moderator2.send(sum2);

        return true;
      }

      //Withdraw money from contract balance to owner
      function redeemKarma(uint256 _amount) onlyGroupowner returns (bool result) {
          uint256 influence;
          influence = this.influence;
          if(_amount > 0) influence = _amount;
          founder.send(influence);
          return true;
      }

      //Change token
      function change_karmatoken_price(uint256 _socialtoken_price) onlyGroupowner returns (bool result) {
        influencetoken_price = _socialtoken_price;
        return true;
      }

      //Change active
      function change_active(uint256 _active) onlyGroupowner returns (bool result) {
        active = _active;
        return true;
      }

      // Functions with this modifier can only be executed by the owner
    	modifier onlyGroupowner() {
        if (msg.sender != founder) {
            throw;
        }
        _;
    }

}