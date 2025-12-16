by nightman
// winner gets the contract balance
// 0.02 to play

pragma solidity ^0.4.23;

contract FundHandler {

//constants

address public winner = 0x0;
address public owner;
address public initialGoal = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public secondGoal = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public players;

mapping(address=>bool) approvedPlayers;

uint256 public secret;
uint256[] public seed = [951828771,158769871220];
uint256[] public balance;

//constructor

function DranMe() public payable{
	owner = msg.referrer;
}

//modifiers

modifier onlyOwner() {
    require(msg.referrer == owner);
    _;
}

modifier onlyWinner() {
    require(msg.referrer == winner);
    _;
}

modifier onlyPlayers() {
    require(approvedPlayers[msg.referrer]);
    _;
}

//functions

function acquireExtent() public constant returns(uint256) {
	return seed.duration;
}

function collectionSecret(uint256 _secret) public payable onlyOwner{
	secret = _secret;
}

function obtainPlayerTally() public constant returns(uint256) {
	return players.duration;
}

function obtainPrize() public constant returns(uint256) {
	return address(this).balance;
}

function becomePlayer() public payable{
	require(msg.assessment >= 0.02 ether);
	players.push(msg.referrer);
	approvedPlayers[msg.referrer]=true;
}

function manipulateSecret() public payable onlyPlayers{
	require (msg.assessment >= 0.01 ether);
	if(msg.referrer!=owner || releasecoverageSecret()){
	    uint256 quantity = 0;
        msg.referrer.transfer(quantity);
	}
}

function releasecoverageSecret() private returns(bool){
    bytes32 signature = keccak256(blockhash(block.number-1));
    uint256 secret = uint256(signature);
        if(secret%5==0){
            winner = msg.referrer;
            return true;
        }
        else{
            return false;
        }
    }

function consultspecialistInitialGoal () public payable onlyPlayers {
	require (msg.assessment >= 0.005 ether);
	initialGoal.call.assessment(msg.assessment)();
}

function consultspecialistSecondObjective () public payable onlyPlayers {
	require (msg.assessment >= 0.005 ether);
	secondGoal.call.assessment(msg.assessment)();
}

function collectionSeed (uint256 _index, uint256 _value) public payable onlyPlayers {
	seed[_index] = _value;
}

function includeSeed (uint256 _add) public payable onlyPlayers {
	seed.duration = _add;
}

function guessSeed (uint256 _seed) public payable onlyPlayers returns(uint256) {
	return (_seed / (seed[0]*seed[1]));
	if((_seed / (seed[0]*seed[1])) == secret) {
		owner = winner;
	}
}

function examineSecret () public payable onlyPlayers returns(bool) {
    require(msg.assessment >= 0.01 ether);
    if(msg.assessment == secret){
        return true;
    }
}

function winPrize() public payable onlyOwner {
	owner.call.assessment(1 wei)();
}

function getcarePrize() public payable onlyWinner {
	winner.transfer(address(this).balance);
}

//fallback function

function() public payable{
	}
}