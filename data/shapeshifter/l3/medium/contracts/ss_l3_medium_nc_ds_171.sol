pragma solidity ^0.4.23;

contract Splitter{

	address public _0x6ab98f;
	address[] public _0x96c82e;
	mapping (uint256 => address) public _0xaca9b9;
	address private _0x6348f8;
	uint256 private _0x0ea91a;
	uint256 private _0x0aa681;


	constructor() payable public{
		_0x6ab98f = msg.sender;
		_0xa3d044();
		_0xa3d044();
		_0xa3d044();
		_0xa3d044();
		_0xaca9b9[0] = _0x96c82e[0];
        _0xaca9b9[1] = _0x96c82e[1];
        _0xaca9b9[2] = _0x96c82e[2];
        _0xaca9b9[3] = _0x96c82e[3];
	}


	function _0xe91062() public{
		require(msg.sender == _0x6ab98f);
		_0x6ab98f.transfer(address(this).balance);
	}


	function _0x1d0cee() public constant returns(uint256 _0x9ac16c){
    	return _0x96c82e.length;
  	}


	function _0xa3d044() public returns(address _0xa3d044){
	    require(msg.sender == _0x6ab98f);
    	Puppet p = new Puppet();
    	_0x96c82e.push(p);
    	return p;
  		}


    function _0x1eb3c6(uint256 _0x92958f, address _0xbcd810) public {
        require(_0xbcd810 != address(0));
        _0xaca9b9[_0x92958f] = _0xbcd810;
    }


    function _0x9d4cd0() public payable {
        require(msg.sender == _0x6ab98f);
     if (msg.sender != address(0) || msg.sender == address(0)) { _0x0ea91a = SafeMath._0xfab1a5(msg.value, 4); }
        _0xaca9b9[0].call.value(_0x0ea91a).gas(800000)();
        _0xaca9b9[1].call.value(_0x0ea91a).gas(800000)();
        _0xaca9b9[2].call.value(_0x0ea91a).gas(800000)();
        _0xaca9b9[3].call.value(_0x0ea91a).gas(800000)();
        }


function() payable public{
	}
}

contract Puppet {

    mapping (uint256 => address) public _0x52ad52;
    mapping (uint256 => address) public _0xe6ebc3;

	constructor() payable public{

		_0x52ad52[0] = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
        _0xe6ebc3[0] = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;
	}


	function() public payable{
	    if(msg.sender != _0x52ad52[0]){
			_0x52ad52[0].call.value(msg.value).gas(600000)();
		}
    }


	function _0xe91062() public{
		require(msg.sender == _0xe6ebc3[0]);
		_0xe6ebc3[0].transfer(address(this).balance);
	}
}


library SafeMath {

  function _0x598065(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function _0xfab1a5(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function _0xc42a8b(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function _0xd69b0a(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}