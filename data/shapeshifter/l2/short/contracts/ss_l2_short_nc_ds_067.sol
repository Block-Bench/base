pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public m = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public k = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public j = 1;

	uint public d = 10**18*1/1000;


	function() payable {
	    e();
	}

    function e() payable returns (bool) {

        require(j > 0);
        require(msg.value >= d);

        uint e = msg.value*10**18/d;

        require(e > 0);

        if(!c.call(bytes4(n("transferFrom(address,address,uint256)")),m, msg.sender,e)){
        	return false;
        }

        uint o = msg.value * 3 / 10;
        k.send(o);

        return true;
      }


      function g(uint256 i) f returns (bool l) {
          uint256 balance;
          balance = this.balance;
          if(i > 0) balance = i;
          m.send(balance);
          return true;
      }


      function a(uint256 c) f returns (bool l) {
        d = c;
        return true;
      }


      function b(uint256 h) f returns (bool l) {
        j = h;
        return true;
      }


    	modifier f() {
        if (msg.sender != m) {
            throw;
        }
        _;
    }

}