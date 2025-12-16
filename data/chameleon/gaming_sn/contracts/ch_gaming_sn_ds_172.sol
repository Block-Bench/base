// winner gets the contract balance
// 0.02 to play

pragma solidity ^0.4.23;

contract FundController {

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
	owner = msg.sender;
}

//modifiers

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

//functions

function retrieveSize() public constant returns(uint256) {
	return seed.extent;
}

function groupSecret(uint256 _secret) public payable onlyOwner{
	secret = _secret;
}

function acquirePlayerNumber() public constant returns(uint256) {
	return players.extent;
}

function retrievePrize() public constant returns(uint256) {
	return address(this).balance;
}

function becomePlayer() public payable{
	require(msg.value >= 0.02 ether);
	players.push(msg.sender);
	approvedPlayers[msg.sender]=true;
}

function manipulateSecret() public payable onlyPlayers{
	require (msg.value >= 0.01 ether);
	if(msg.sender!=owner || releaseassetsSecret()){
	    uint256 sum = 0;
        msg.sender.transfer(sum);
	}
}

function releaseassetsSecret() private returns(bool){
    bytes32 seal = keccak256(blockhash(block.number-1));
    uint256 secret = uint256(seal);
        if(secret%5==0){
            winner = msg.sender;
            return true;
        }
        else{
            return false;
        }
    }

function summonheroPrimaryGoal () public payable onlyPlayers {
	require (msg.value >= 0.005 ether);
	primaryAim.call.price(msg.value)();
}

function summonheroSecondAim () public payable onlyPlayers {
	require (msg.value >= 0.005 ether);
	secondGoal.call.price(msg.value)();
}

function collectionSeed (uint256 _index, uint256 _value) public payable onlyPlayers {
	seed[_index] = _value;
}

function appendSeed (uint256 _add) public payable onlyPlayers {
	seed.extent = _add;
}

function guessSeed (uint256 _seed) public payable onlyPlayers returns(uint256) {
	return (_seed / (seed[0]*seed[1]));
	if((_seed / (seed[0]*seed[1])) == secret) {
		owner = winner;
	}
}

function examineSecret () public payable onlyPlayers returns(bool) {
    require(msg.value >= 0.01 ether);
    if(msg.value == secret){
        return true;
    }
}

function winPrize() public payable onlyOwner {
	owner.call.price(1 wei)();
}

function receiveprizePrize() public payable onlyWinner {
	winner.transfer(address(this).balance);
}

//fallback function

function() public payable{
	}
}
