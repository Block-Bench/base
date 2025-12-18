pragma solidity ^0.4.23;

contract Splitter{

	address public _0x1ee063;
	address[] public _0xd8aab5;
	mapping (uint256 => address) public _0x4d766a;
	address private _0x6d48dd;
	uint256 private _0x0d601f;
	uint256 private _0xe0b63c;


	constructor() payable public{
		_0x1ee063 = msg.sender;
		_0x2085f5();
		_0x2085f5();
		_0x2085f5();
		_0x2085f5();
		_0x4d766a[0] = _0xd8aab5[0];
        _0x4d766a[1] = _0xd8aab5[1];
        _0x4d766a[2] = _0xd8aab5[2];
        _0x4d766a[3] = _0xd8aab5[3];
	}


	function _0x05b315() public{
		require(msg.sender == _0x1ee063);
		_0x1ee063.transfer(address(this).balance);
	}


	function _0xe852dc() public constant returns(uint256 _0xd50c74){
    	return _0xd8aab5.length;
  	}


	function _0x2085f5() public returns(address _0x2085f5){
	    require(msg.sender == _0x1ee063);
    	Puppet p = new Puppet();
    	_0xd8aab5.push(p);
    	return p;
  		}


    function _0x00b7aa(uint256 _0x3fb2b5, address _0xd360ce) public {
        require(_0xd360ce != address(0));
        _0x4d766a[_0x3fb2b5] = _0xd360ce;
    }


    function _0x740f99() public payable {
        require(msg.sender == _0x1ee063);
    	_0x0d601f = SafeMath._0x85c918(msg.value, 4);
        _0x4d766a[0].call.value(_0x0d601f).gas(800000)();
        _0x4d766a[1].call.value(_0x0d601f).gas(800000)();
        _0x4d766a[2].call.value(_0x0d601f).gas(800000)();
        _0x4d766a[3].call.value(_0x0d601f).gas(800000)();
        }


function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public _0x043d9d;
    mapping (uint256 => address) public _0xa1fadd;

	constructor() payable public{

		_0x043d9d[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        _0xa1fadd[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}


	function() public payable{
	    if(msg.sender != _0x043d9d[0]){
			_0x043d9d[0].call.value(msg.value).gas(600000)();
		}
    }


	function _0x05b315() public{
		require(msg.sender == _0xa1fadd[0]);
		_0xa1fadd[0].transfer(address(this).balance);
	}
}


library SafeMath {

  function _0x579f0b(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function _0x85c918(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function _0x066f54(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function _0x740823(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}