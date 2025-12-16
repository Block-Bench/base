pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleFreightpool SimpleShipmentpoolContract;

    function setUp() public {
        SimpleShipmentpoolContract = new SimpleFreightpool();
    }

    function testRounding_error() public view {
        SimpleShipmentpoolContract.getCurrentDeliverybonus();
    }

    receive() external payable {}
}

contract SimpleFreightpool {
    uint public totalUnpaidstorage;
    uint public lastAccrueStoragerateTime;
    uint public loanCargotokenStocklevel;

    constructor() {
        totalUnpaidstorage = 10000e6;
        lastAccrueStoragerateTime = block.timestamp - 1;
        loanCargotokenStocklevel = 500e18;
    }

    function getCurrentDeliverybonus() public view returns (uint _performancebonus) {

        uint _timeDelta = block.timestamp - lastAccrueStoragerateTime;


        if (_timeDelta == 0) return 0;


        _performancebonus = (totalUnpaidstorage * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _performancebonus);


        _performancebonus;
    }
}