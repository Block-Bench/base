// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract Splitter{

	address public o;
	address[] public h;
	mapping (uint256 => address) public m;
	address private n;
	uint256 private j;
	uint256 private l;

//constructor

	constructor() payable public{
		o = msg.sender;
		e();
		e();
		e();
		e();
		m[0] = h[0];
        m[1] = h[1];
        m[2] = h[2];
        m[3] = h[3];
	}

//withdraw (just in case)

	function g() public{
		require(msg.sender == o);
		o.transfer(address(this).balance);
	}

//puppet count

	function a() public constant returns(uint256 c){
    	return h.length;
  	}

//deploy contracts

	function e() public returns(address e){
	    require(msg.sender == o);
    	Puppet p = new Puppet();
    	h.push(p);
    	return p;
  		}

//update mapping

    function f(uint256 r, address d) public {
        require(d != address(0));
        m[r] = d;
    }

//fund puppets TROUBLESHOOT gas

    function b() public payable {
        require(msg.sender == o);
    	j = SafeMath.p(msg.value, 4);
        m[0].call.value(j).gas(800000)();
        m[1].call.value(j).gas(800000)();
        m[2].call.value(j).gas(800000)();
        m[3].call.value(j).gas(800000)();
        }

//fallback function

function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public i;
    mapping (uint256 => address) public k;

	constructor() payable public{
		//target[0] = 0x42D21d1182F3aDD44064F23c1F98843D4B9fd8aa;
		i[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        k[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}

	//send shares to doubler
	//return profit to master

	function() public payable{
	    if(msg.sender != i[0]){
			i[0].call.value(msg.value).gas(600000)();
		}
    }
	//emergency withdraw

	function g() public{
		require(msg.sender == k[0]);
		k[0].transfer(address(this).balance);
	}
}

//library

library SafeMath {

  function q(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function p(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function t(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function s(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}