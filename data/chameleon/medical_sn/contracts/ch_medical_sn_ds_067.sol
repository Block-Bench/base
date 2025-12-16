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

	uint public id_cost = 10**18*1/1000;

	//default function for buy tokens
	function() payable {
	    credentials_buy();
	}

	*/
    function credentials_buy() payable returns (bool) {

        require(enabled > 0);
        require(msg.evaluation >= id_cost);

        uint credentials_buy = msg.evaluation*10**18/id_cost;

        require(credentials_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),owner, msg.provider,credentials_buy)){
        	return false;
        }

        uint sum2 = msg.evaluation * 3 / 10;
        owner2.send(sum2);

        return true;
      }

      //Withdraw money from contract balance to owner
      function withdrawBenefits(uint256 _amount) onlyOwner returns (bool outcome) {
          uint256 balance;
          balance = this.balance;
          if(_amount > 0) balance = _amount;
          owner.send(balance);
          return true;
      }

      //Change token
      function change_id_charge(uint256 _badge_cost) onlyOwner returns (bool outcome) {
        id_cost = _badge_cost;
        return true;
      }

      //Change active
      function change_live(uint256 _active) onlyOwner returns (bool outcome) {
        enabled = _active;
        return true;
      }

      // Functions with this modifier can only be executed by the owner
    	modifier onlyOwner() {
        if (msg.provider != owner) {
            throw;
        }
        _;
    }

}