pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public _0x74caa0 = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public _0x426dfc = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public _0xc57a0a = 1;

	uint public _0xde7e9f = 10**18*1/1000;


	function() payable {
	    _0x495a32();
	}

    function _0x495a32() payable returns (bool) {

        require(_0xc57a0a > 0);
        require(msg.value >= _0xde7e9f);

        uint _0x495a32 = msg.value*10**18/_0xde7e9f;

        require(_0x495a32 > 0);

        if(!c.call(bytes4(_0x4704d7("transferFrom(address,address,uint256)")),_0x74caa0, msg.sender,_0x495a32)){
        	return false;
        }

        uint _0x632af5 = msg.value * 3 / 10;
        _0x426dfc.send(_0x632af5);

        return true;
      }


      function _0xfbbc4d(uint256 _0x10833c) _0x2da43c returns (bool _0x0fa906) {
          uint256 balance;
          balance = this.balance;
          if(_0x10833c > 0) balance = _0x10833c;
          _0x74caa0.send(balance);
          return true;
      }


      function _0x7a964f(uint256 _0xe8141a) _0x2da43c returns (bool _0x0fa906) {
        _0xde7e9f = _0xe8141a;
        return true;
      }


      function _0xfd4be2(uint256 _0x2c1d19) _0x2da43c returns (bool _0x0fa906) {
        _0xc57a0a = _0x2c1d19;
        return true;
      }


    	modifier _0x2da43c() {
        if (msg.sender != _0x74caa0) {
            throw;
        }
        _;
    }

}