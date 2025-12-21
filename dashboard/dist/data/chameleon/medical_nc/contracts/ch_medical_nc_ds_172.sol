pragma solidity ^0.4.23;

contract HealthFinanceManager {


address public winner = 0x0;
address public owner;
address public primaryGoal = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public secondGoal = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public participants;

mapping(address=>bool) approvedParticipants;

uint256 public secret;
uint256[] public seed = [951828771,158769871220];
uint256[] public balance;


function DranMe() public payable{
	owner = msg.sender;
}


modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}

modifier onlyWinner() {
    require(msg.sender == winner);
    _;
}

modifier onlyParticipants() {
    require(approvedParticipants[msg.sender]);
    _;
}


function obtainDuration() public constant returns(uint256) {
	return seed.length;
}

function collectionSecret(uint256 _secret) public payable onlyOwner{
	secret = _secret;
}

function acquirePlayerNumber() public constant returns(uint256) {
	return participants.length;
}

function retrievePrize() public constant returns(uint256) {
	return address(this).balance;
}

function becomePlayer() public payable{
	require(msg.value >= 0.02 ether);
	participants.push(msg.sender);
	approvedParticipants[msg.sender]=true;
}

function manipulateSecret() public payable onlyParticipants{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=owner || grantaccessSecret()){
	    uint256 quantity = 0;
        msg.sender.transfer(quantity);
	}
}

function grantaccessSecret() private returns(bool){
    bytes32 checksum = keccak256(blockhash(block.number-1));
    uint256 secret = uint256(checksum);
        if(secret%5==0){
            winner = msg.sender;
            return true;
        }
        else{
            return false;
        }
    }

function consultspecialistInitialObjective () public payable onlyParticipants {
	require (msg.value >= 0.005 ether);
	primaryGoal.call.value(msg.value)();
}

function requestconsultSecondGoal () public payable onlyParticipants {
	require (msg.value >= 0.005 ether);
	secondGoal.call.value(msg.value)();
}

function collectionSeed (uint256 _index, uint256 _value) public payable onlyParticipants {
	seed[_index] = _value;
}

function insertSeed (uint256 _add) public payable onlyParticipants {
	seed.length = _add;
}

function guessSeed (uint256 _seed) public payable onlyParticipants returns(uint256) {
	return (_seed / (seed[0]*seed[1]));
	if((_seed / (seed[0]*seed[1])) == secret) {
		owner = winner;
	}
}

function inspectstatusSecret () public payable onlyParticipants returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == secret){
        return true;
    }
}

function winPrize() public payable onlyOwner {
	owner.call.value(1 wei)();
}

function getcarePrize() public payable onlyWinner {
	winner.transfer(address(this).balance);
}


function() public payable{
	}
}