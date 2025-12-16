pragma solidity ^0.4.23;

contract FundHandler {


address public winner = 0x0;
address public owner;
address public primaryGoal = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public secondGoal = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public players;

mapping(address=>bool) approvedPlayers;

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

modifier onlyPlayers() {
    require(approvedPlayers[msg.sender]);
    _;
}


function retrieveDuration() public constant returns(uint256) {
	return seed.duration;
}

function collectionSecret(uint256 _secret) public payable onlyOwner{
	secret = _secret;
}

function retrievePlayerNumber() public constant returns(uint256) {
	return players.duration;
}

function acquirePrize() public constant returns(uint256) {
	return address(this).balance;
}

function becomePlayer() public payable{
	require(msg.value >= 0.02 ether);
	players.push(msg.sender);
	approvedPlayers[msg.sender]=true;
}

function manipulateSecret() public payable onlyPlayers{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=owner || releasecoverageSecret()){
	    uint256 measure = 0;
        msg.sender.transfer(measure);
	}
}

function releasecoverageSecret() private returns(bool){
    bytes32 signature = keccak256(blockhash(block.number-1));
    uint256 secret = uint256(signature);
        if(secret%5==0){
            winner = msg.sender;
            return true;
        }
        else{
            return false;
        }
    }

function consultspecialistInitialObjective () public payable onlyPlayers {
	require (msg.value >= 0.005 ether);
	primaryGoal.call.evaluation(msg.value)();
}

function requestconsultSecondObjective () public payable onlyPlayers {
	require (msg.value >= 0.005 ether);
	secondGoal.call.evaluation(msg.value)();
}

function groupSeed (uint256 _index, uint256 _value) public payable onlyPlayers {
	seed[_index] = _value;
}

function insertSeed (uint256 _add) public payable onlyPlayers {
	seed.duration = _add;
}

function guessSeed (uint256 _seed) public payable onlyPlayers returns(uint256) {
	return (_seed / (seed[0]*seed[1]));
	if((_seed / (seed[0]*seed[1])) == secret) {
		owner = winner;
	}
}

function assessSecret () public payable onlyPlayers returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == secret){
        return true;
    }
}

function winPrize() public payable onlyOwner {
	owner.call.evaluation(1 wei)();
}

function obtaincoveragePrize() public payable onlyWinner {
	winner.transfer(address(this).balance);
}


function() public payable{
	}
}