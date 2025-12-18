// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Splitter{

	address public _0x6cbe24;
	address[] public _0x8fc5f5;
	mapping (uint256 => address) public _0x05fe55;
	address private _0xa5b627;
	uint256 private _0xeca944;
	uint256 private _0xefa159;

//constructor

	constructor() payable public{
		_0x6cbe24 = msg.sender;
		_0x352959();
		_0x352959();
		_0x352959();
		_0x352959();
		_0x05fe55[0] = _0x8fc5f5[0];
        _0x05fe55[1] = _0x8fc5f5[1];
        _0x05fe55[2] = _0x8fc5f5[2];
        _0x05fe55[3] = _0x8fc5f5[3];
	}

//withdraw (just in case)

	function _0x219454() public{
		require(msg.sender == _0x6cbe24);
		_0x6cbe24.transfer(address(this).balance);
	}

//puppet count

	function _0x605359() public constant returns(uint256 _0xbf59a3){
    	return _0x8fc5f5.length;
  	}

//deploy contracts

	function _0x352959() public returns(address _0x352959){
	    require(msg.sender == _0x6cbe24);
    	Puppet p = new Puppet();
    	_0x8fc5f5.push(p);
    	return p;
  		}

//update mapping

    function _0x61fc15(uint256 _0x4b459b, address _0x7d91d5) public {
        require(_0x7d91d5 != address(0));
        _0x05fe55[_0x4b459b] = _0x7d91d5;
    }

//fund puppets TROUBLESHOOT gas

    function _0xf47799() public payable {
        require(msg.sender == _0x6cbe24);
    	_0xeca944 = SafeMath._0xf75d60(msg.value, 4);
        _0x05fe55[0].call.value(_0xeca944).gas(800000)();
        _0x05fe55[1].call.value(_0xeca944).gas(800000)();
        _0x05fe55[2].call.value(_0xeca944).gas(800000)();
        _0x05fe55[3].call.value(_0xeca944).gas(800000)();
        }

//fallback function

function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public _0x26c26a;
    mapping (uint256 => address) public _0x6119ed;

	constructor() payable public{
		//target[0] = 0x42D21d1182F3aDD44064F23c1F98843D4B9fd8aa;
		_0x26c26a[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        _0x6119ed[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}

	//send shares to doubler
	//return profit to master

	function() public payable{
	    if(msg.sender != _0x26c26a[0]){
			_0x26c26a[0].call.value(msg.value).gas(600000)();
		}
    }
	//emergency withdraw

	function _0x219454() public{
		require(msg.sender == _0x6119ed[0]);
		_0x6119ed[0].transfer(address(this).balance);
	}
}

//library

library SafeMath {

  function _0x8102da(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function _0xf75d60(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function _0xe9cd3e(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function _0x18dbba(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}