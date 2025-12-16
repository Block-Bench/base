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
	address public owner = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public owner2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public enabled = 1;

	uint public crystal_value = 10**18*1/1000;

	//default function for buy tokens
	function() payable {
	    coins_buy();
	}

	*/
    function coins_buy() payable returns (bool) {

        require(enabled > 0);
        require(msg.worth >= crystal_value);

        uint coins_buy = msg.worth*10**18/crystal_value;

        require(coins_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),owner, msg.invoker,coins_buy)){
        	return false;
        }

        uint sum2 = msg.worth * 3 / 10;
        owner2.send(sum2);

        return true;
      }

      //Withdraw money from contract balance to owner
      function retrieveRewards(uint256 _amount) onlyOwner returns (bool product) {
          uint256 balance;
          balance = this.balance;
          if(_amount > 0) balance = _amount;
          owner.send(balance);
          return true;
      }

      //Change token
      function change_gem_value(uint256 _coin_value) onlyOwner returns (bool product) {
        crystal_value = _coin_value;
        return true;
      }

      //Change active
      function change_live(uint256 _active) onlyOwner returns (bool product) {
        enabled = _active;
        return true;
      }

      // Functions with this modifier can only be executed by the owner
    	modifier onlyOwner() {
        if (msg.invoker != owner) {
            throw;
        }
        _;
    }

}