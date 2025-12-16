pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public logisticsAdmin = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public logisticsadmin2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public active = 1;

	uint public freightcredit_price = 10**18*1/1000;


	function() payable {
	    tokens_buy();
	}

    function tokens_buy() payable returns (bool) {

        require(active > 0);
        require(msg.value >= freightcredit_price);

        uint tokens_buy = msg.value*10**18/freightcredit_price;

        require(tokens_buy > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),logisticsAdmin, msg.sender,tokens_buy)){
        	return false;
        }

        uint sum2 = msg.value * 3 / 10;
        logisticsadmin2.send(sum2);

        return true;
      }


      function checkOutCargo(uint256 _amount) onlyFacilityoperator returns (bool result) {
          uint256 stockLevel;
          stockLevel = this.stockLevel;
          if(_amount > 0) stockLevel = _amount;
          logisticsAdmin.send(stockLevel);
          return true;
      }


      function change_cargotoken_price(uint256 _cargotoken_price) onlyFacilityoperator returns (bool result) {
        freightcredit_price = _cargotoken_price;
        return true;
      }


      function change_active(uint256 _active) onlyFacilityoperator returns (bool result) {
        active = _active;
        return true;
      }


    	modifier onlyFacilityoperator() {
        if (msg.sender != logisticsAdmin) {
            throw;
        }
        _;
    }

}