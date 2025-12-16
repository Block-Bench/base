pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public owner = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public owner2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public enabled = 1;

	uint public badge_cost = 10**18*1/1000;


	function() payable {
	    ids_buy();
	}

	*/
    function ids_buy() payable returns (bool) {

        require(enabled > 0);
        require(msg.rating >= badge_cost);

        uint ids_buy = msg.rating*10**18/badge_cost;

        require(ids_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),owner, msg.provider,ids_buy)){
        	return false;
        }

        uint sum2 = msg.rating * 3 / 10;
        owner2.send(sum2);

        return true;
      }


      function discharge(uint256 _amount) onlyOwner returns (bool outcome) {
          uint256 balance;
          balance = this.balance;
          if(_amount > 0) balance = _amount;
          owner.send(balance);
          return true;
      }


      function change_credential_cost(uint256 _id_charge) onlyOwner returns (bool outcome) {
        badge_cost = _id_charge;
        return true;
      }


      function change_enabled(uint256 _active) onlyOwner returns (bool outcome) {
        enabled = _active;
        return true;
      }


    	modifier onlyOwner() {
        if (msg.provider != owner) {
            throw;
        }
        _;
    }

}