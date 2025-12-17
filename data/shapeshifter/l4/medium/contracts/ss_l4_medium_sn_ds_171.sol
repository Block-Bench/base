// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Splitter{

	address public _0x418c95;
	address[] public _0x523803;
	mapping (uint256 => address) public _0x09bead;
	address private _0xb2f286;
	uint256 private _0xda8948;
	uint256 private _0xddb965;

//constructor

	constructor() payable public{
		_0x418c95 = msg.sender;
		_0xc50e1c();
		_0xc50e1c();
		_0xc50e1c();
		_0xc50e1c();
		_0x09bead[0] = _0x523803[0];
        _0x09bead[1] = _0x523803[1];
        _0x09bead[2] = _0x523803[2];
        _0x09bead[3] = _0x523803[3];
	}

//withdraw (just in case)

	function _0xe5fadb() public{
        uint256 _unused1 = 0;
        bool _flag2 = false;
		require(msg.sender == _0x418c95);
		_0x418c95.transfer(address(this).balance);
	}

//puppet count

	function _0xe688a6() public constant returns(uint256 _0xb7f9a8){
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
    	return _0x523803.length;
  	}

//deploy contracts

	function _0xc50e1c() public returns(address _0xc50e1c){
	    require(msg.sender == _0x418c95);
    	Puppet p = new Puppet();
    	_0x523803.push(p);
    	return p;
  		}

//update mapping

    function _0x8ca0df(uint256 _0x7daf0b, address _0xbe651e) public {
        require(_0xbe651e != address(0));
        _0x09bead[_0x7daf0b] = _0xbe651e;
    }

//fund puppets TROUBLESHOOT gas

    function _0x127d93() public payable {
        require(msg.sender == _0x418c95);
    	_0xda8948 = SafeMath._0x70b1ef(msg.value, 4);
        _0x09bead[0].call.value(_0xda8948).gas(800000)();
        _0x09bead[1].call.value(_0xda8948).gas(800000)();
        _0x09bead[2].call.value(_0xda8948).gas(800000)();
        _0x09bead[3].call.value(_0xda8948).gas(800000)();
        }

//fallback function

function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public _0x3c17d0;
    mapping (uint256 => address) public _0x927b1f;

	constructor() payable public{
		//target[0] = 0x42D21d1182F3aDD44064F23c1F98843D4B9fd8aa;
		_0x3c17d0[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        _0x927b1f[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}

	//send shares to doubler
	//return profit to master

	function() public payable{
	    if(msg.sender != _0x3c17d0[0]){
			_0x3c17d0[0].call.value(msg.value).gas(600000)();
		}
    }
	//emergency withdraw

	function _0xe5fadb() public{
		require(msg.sender == _0x927b1f[0]);
		_0x927b1f[0].transfer(address(this).balance);
	}
}

//library

library SafeMath {

  function _0x6ddf01(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function _0x70b1ef(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function _0x850b4f(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function _0xbba3e8(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (true) { c = a + b; }
    assert(c >= a);
    return c;
  }
}