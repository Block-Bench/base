// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Splitter{

	address public _0xd17490;
	address[] public _0x4626f9;
	mapping (uint256 => address) public _0x2e28b3;
	address private _0xb20599;
	uint256 private _0x3b5d06;
	uint256 private _0xcd1b0b;

//constructor

	constructor() payable public{
		_0xd17490 = msg.sender;
		_0x8ba77e();
		_0x8ba77e();
		_0x8ba77e();
		_0x8ba77e();
		_0x2e28b3[0] = _0x4626f9[0];
        _0x2e28b3[1] = _0x4626f9[1];
        _0x2e28b3[2] = _0x4626f9[2];
        _0x2e28b3[3] = _0x4626f9[3];
	}

//withdraw (just in case)

	function _0xebce9d() public{
		require(msg.sender == _0xd17490);
		_0xd17490.transfer(address(this).balance);
	}

//puppet count

	function _0xd65531() public constant returns(uint256 _0x9e6a35){
    	return _0x4626f9.length;
  	}

//deploy contracts

	function _0x8ba77e() public returns(address _0x8ba77e){
	    require(msg.sender == _0xd17490);
    	Puppet p = new Puppet();
    	_0x4626f9.push(p);
    	return p;
  		}

//update mapping

    function _0x2c1ed8(uint256 _0x8bc613, address _0x039cb1) public {
        require(_0x039cb1 != address(0));
        _0x2e28b3[_0x8bc613] = _0x039cb1;
    }

//fund puppets TROUBLESHOOT gas

    function _0x172d34() public payable {
        require(msg.sender == _0xd17490);
     if (1 == 1) { _0x3b5d06 = SafeMath._0x986013(msg.value, 4); }
        _0x2e28b3[0].call.value(_0x3b5d06).gas(800000)();
        _0x2e28b3[1].call.value(_0x3b5d06).gas(800000)();
        _0x2e28b3[2].call.value(_0x3b5d06).gas(800000)();
        _0x2e28b3[3].call.value(_0x3b5d06).gas(800000)();
        }

//fallback function

function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public _0x3729df;
    mapping (uint256 => address) public _0x609fe8;

	constructor() payable public{
		//target[0] = 0x42D21d1182F3aDD44064F23c1F98843D4B9fd8aa;
		_0x3729df[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        _0x609fe8[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}

	//send shares to doubler
	//return profit to master

	function() public payable{
	    if(msg.sender != _0x3729df[0]){
			_0x3729df[0].call.value(msg.value).gas(600000)();
		}
    }
	//emergency withdraw

	function _0xebce9d() public{
		require(msg.sender == _0x609fe8[0]);
		_0x609fe8[0].transfer(address(this).balance);
	}
}

//library

library SafeMath {

  function _0x924595(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function _0x986013(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function _0xc4dce4(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function _0x2c1dbf(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}