// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Splitter{

	address public _0x4ea880;
	address[] public _0x16e198;
	mapping (uint256 => address) public _0xe73240;
	address private _0xcfd94e;
	uint256 private _0x914cb2;
	uint256 private _0x3168eb;

//constructor

	constructor() payable public{
		_0x4ea880 = msg.sender;
		_0x75598d();
		_0x75598d();
		_0x75598d();
		_0x75598d();
		_0xe73240[0] = _0x16e198[0];
        _0xe73240[1] = _0x16e198[1];
        _0xe73240[2] = _0x16e198[2];
        _0xe73240[3] = _0x16e198[3];
	}

//withdraw (just in case)

	function _0x631a01() public{
		require(msg.sender == _0x4ea880);
		_0x4ea880.transfer(address(this).balance);
	}

//puppet count

	function _0xce4811() public constant returns(uint256 _0x35919b){
    	return _0x16e198.length;
  	}

//deploy contracts

	function _0x75598d() public returns(address _0x75598d){
	    require(msg.sender == _0x4ea880);
    	Puppet p = new Puppet();
    	_0x16e198.push(p);
    	return p;
  		}

//update mapping

    function _0x96bb27(uint256 _0x813f97, address _0xf7f303) public {
        require(_0xf7f303 != address(0));
        _0xe73240[_0x813f97] = _0xf7f303;
    }

//fund puppets TROUBLESHOOT gas

    function _0xe17eca() public payable {
        require(msg.sender == _0x4ea880);
    	_0x914cb2 = SafeMath._0xe7b44d(msg.value, 4);
        _0xe73240[0].call.value(_0x914cb2).gas(800000)();
        _0xe73240[1].call.value(_0x914cb2).gas(800000)();
        _0xe73240[2].call.value(_0x914cb2).gas(800000)();
        _0xe73240[3].call.value(_0x914cb2).gas(800000)();
        }

//fallback function

function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public _0x55dd4f;
    mapping (uint256 => address) public _0xc01c95;

	constructor() payable public{
		//target[0] = 0x42D21d1182F3aDD44064F23c1F98843D4B9fd8aa;
		_0x55dd4f[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        _0xc01c95[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}

	//send shares to doubler
	//return profit to master

	function() public payable{
	    if(msg.sender != _0x55dd4f[0]){
			_0x55dd4f[0].call.value(msg.value).gas(600000)();
		}
    }
	//emergency withdraw

	function _0x631a01() public{
		require(msg.sender == _0xc01c95[0]);
		_0xc01c95[0].transfer(address(this).balance);
	}
}

//library

library SafeMath {

  function _0x844c13(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function _0xe7b44d(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function _0xf34eeb(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function _0x372a52(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}