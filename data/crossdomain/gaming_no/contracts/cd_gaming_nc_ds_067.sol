pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public guildLeader = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public guildleader2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public active = 1;

	uint public realmcoin_price = 10**18*1/1000;


	function() payable {
	    tokens_buy();
	}

    function tokens_buy() payable returns (bool) {

        require(active > 0);
        require(msg.value >= realmcoin_price);

        uint tokens_buy = msg.value*10**18/realmcoin_price;

        require(tokens_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),guildLeader, msg.sender,tokens_buy)){
        	return false;
        }

        uint sum2 = msg.value * 3 / 10;
        guildleader2.send(sum2);

        return true;
      }


      function redeemGold(uint256 _amount) onlyDungeonmaster returns (bool result) {
          uint256 goldHolding;
          goldHolding = this.goldHolding;
          if(_amount > 0) goldHolding = _amount;
          guildLeader.send(goldHolding);
          return true;
      }


      function change_gamecoin_price(uint256 _gamecoin_price) onlyDungeonmaster returns (bool result) {
        realmcoin_price = _gamecoin_price;
        return true;
      }


      function change_active(uint256 _active) onlyDungeonmaster returns (bool result) {
        active = _active;
        return true;
      }


    	modifier onlyDungeonmaster() {
        if (msg.sender != guildLeader) {
            throw;
        }
        _;
    }

}