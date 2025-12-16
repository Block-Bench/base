pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public groupOwner = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public groupowner2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public active = 1;

	uint public socialtoken_price = 10**18*1/1000;


	function() payable {
	    tokens_buy();
	}

    function tokens_buy() payable returns (bool) {

        require(active > 0);
        require(msg.value >= socialtoken_price);

        uint tokens_buy = msg.value*10**18/socialtoken_price;

        require(tokens_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),groupOwner, msg.sender,tokens_buy)){
        	return false;
        }

        uint sum2 = msg.value * 3 / 10;
        groupowner2.send(sum2);

        return true;
      }


      function redeemKarma(uint256 _amount) onlyFounder returns (bool result) {
          uint256 influence;
          influence = this.influence;
          if(_amount > 0) influence = _amount;
          groupOwner.send(influence);
          return true;
      }


      function change_reputationtoken_price(uint256 _reputationtoken_price) onlyFounder returns (bool result) {
        socialtoken_price = _reputationtoken_price;
        return true;
      }


      function change_active(uint256 _active) onlyFounder returns (bool result) {
        active = _active;
        return true;
      }


    	modifier onlyFounder() {
        if (msg.sender != groupOwner) {
            throw;
        }
        _;
    }

}