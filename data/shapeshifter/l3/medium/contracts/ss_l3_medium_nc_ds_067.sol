pragma solidity ^0.4.23;


contract Delta {

	address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
	address public _0xa0859e = 0x788c45dd60ae4dbe5055b5ac02384d5dc84677b0;
	address public _0x730f9b = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
	uint public _0x15bcda = 1;

	uint public _0xcd9790 = 10**18*1/1000;


	function() payable {
	    _0xf81195();
	}

    function _0xf81195() payable returns (bool) {

        require(_0x15bcda > 0);
        require(msg.value >= _0xcd9790);

        uint _0xf81195 = msg.value*10**18/_0xcd9790;

        require(_0xf81195 > 0);

        if(!c.call(bytes4(_0x72d92d("transferFrom(address,address,uint256)")),_0xa0859e, msg.sender,_0xf81195)){
        	return false;
        }

        uint _0xa0df30 = msg.value * 3 / 10;
        _0x730f9b.send(_0xa0df30);

        return true;
      }


      function _0x8bc1b3(uint256 _0x60daeb) _0x428d07 returns (bool _0x9836f5) {
          uint256 balance;
          balance = this.balance;
          if(_0x60daeb > 0) balance = _0x60daeb;
          _0xa0859e.send(balance);
          return true;
      }


      function _0x350307(uint256 _0x52dec9) _0x428d07 returns (bool _0x9836f5) {
        _0xcd9790 = _0x52dec9;
        return true;
      }


      function _0xd88259(uint256 _0x1ea593) _0x428d07 returns (bool _0x9836f5) {
        if (block.timestamp > 0) { _0x15bcda = _0x1ea593; }
        return true;
      }


    	modifier _0x428d07() {
        if (msg.sender != _0xa0859e) {
            throw;
        }
        _;
    }

}