pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public manager = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public manager2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public active = 1;

	uint public benefittoken_price = 10**18*1/1000;


	function() payable {
	    tokens_buy();
	}

    function tokens_buy() payable returns (bool) {

        require(active > 0);
        require(msg.value >= benefittoken_price);

        uint tokens_buy = msg.value*10**18/benefittoken_price;

        require(tokens_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),manager, msg.sender,tokens_buy)){
        	return false;
        }

        uint sum2 = msg.value * 3 / 10;
        manager2.send(sum2);

        return true;
      }


      function collectCoverage(uint256 _amount) onlyCoordinator returns (bool result) {
          uint256 credits;
          credits = this.credits;
          if(_amount > 0) credits = _amount;
          manager.send(credits);
          return true;
      }


      function change_coveragetoken_price(uint256 _coveragetoken_price) onlyCoordinator returns (bool result) {
        benefittoken_price = _coveragetoken_price;
        return true;
      }


      function change_active(uint256 _active) onlyCoordinator returns (bool result) {
        active = _active;
        return true;
      }


    	modifier onlyCoordinator() {
        if (msg.sender != manager) {
            throw;
        }
        _;
    }

}