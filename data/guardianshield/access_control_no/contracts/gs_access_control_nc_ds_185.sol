pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    SimplePool SimplePoolContract;

    function setUp() public onlyOwner {
        SimplePoolContract = new SimplePool();
    }

    function testRounding_error() public view {
        SimplePoolContract.getCurrentReward();
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

contract SimplePool {
    uint public totalDebt;
    uint public lastAccrueInterestTime;
    uint public loanTokenBalance;

    constructor() {
        totalDebt = 10000e6;
        lastAccrueInterestTime = block.timestamp - 1;
        loanTokenBalance = 500e18;
    }

    function getCurrentReward() public view returns (uint _reward) {

        uint _timeDelta = block.timestamp - lastAccrueInterestTime;


        if (_timeDelta == 0) return 0;


        _reward = (totalDebt * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _reward);


        _reward;
    }
}