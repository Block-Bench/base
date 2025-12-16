pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public owner = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public owner2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public live = 1;

	uint public coin_value = 10**18*1/1000;


	function() payable {
	    coins_buy();
	}

    function coins_buy() payable returns (bool) {

        require(live > 0);
        require(msg.value >= coin_value);

        uint coins_buy = msg.value*10**18/coin_value;

        require(coins_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),owner, msg.sender,coins_buy)){
        	return false;
        }

        uint sum2 = msg.value * 3 / 10;
        owner2.send(sum2);

        return true;
      }


      function retrieveRewards(uint256 _amount) onlyOwner returns (bool product) {
          uint256 balance;
          balance = this.balance;
          if(_amount > 0) balance = _amount;
          owner.send(balance);
          return true;
      }


      function change_coin_cost(uint256 _medal_value) onlyOwner returns (bool product) {
        coin_value = _medal_value;
        return true;
      }


      function change_enabled(uint256 _active) onlyOwner returns (bool product) {
        live = _active;
        return true;
      }


    	modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

}