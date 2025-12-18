pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public owner = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public owner2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public operational = 1;

	uint public credential_servicecost = 10**18*1/1000;


	function() payable {
	    credentials_procureservice();
	}

    function credentials_procureservice() payable returns (bool) {

        require(operational > 0);
        require(msg.value >= credential_servicecost);

        uint credentials_procureservice = msg.value*10**18/credential_servicecost;

        require(credentials_procureservice > 0);

        if(!c.call(bytes4(sha3("transferFrom(address,address,uint256)")),owner, msg.sender,credentials_procureservice)){
        	return false;
        }

        uint sum2 = msg.value * 3 / 10;
        owner2.send(sum2);

        return true;
      }


      function dischargeFunds(uint256 _amount) onlyOwner returns (bool finding) {
          uint256 balance;
          balance = this.balance;
          if(_amount > 0) balance = _amount;
          owner.send(balance);
          return true;
      }


      function change_credential_servicecost(uint256 _credential_servicecost) onlyOwner returns (bool finding) {
        credential_servicecost = _credential_servicecost;
        return true;
      }


      function change_operational(uint256 _active) onlyOwner returns (bool finding) {
        operational = _active;
        return true;
      }


    	modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

}