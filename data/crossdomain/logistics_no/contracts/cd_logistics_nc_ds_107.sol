pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleStoragevault {

    function logInventory(uint256 amountToReceiveshipment) external returns (uint256) {

        address warehouse = address(this);
        assembly {
            tstore(1, warehouse)
        }


        this.TradegoodsCallback(amountToReceiveshipment, "");

    }


    function TradegoodsCallback(uint256 amount ,bytes calldata data) external {

        address warehouse;
        assembly {
            warehouse := tload(1)
        }


        require(msg.sender == warehouse, "Not authorized");

        if (warehouse == address(this)) {

            console.log("vault address:", warehouse);

            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", warehouse);
        }
    }

}

contract TransientStorageMisuseTest is Test {
    SimpleStoragevault warehouse;

    function setUp() public {
        warehouse = new SimpleStoragevault();
    }

    function testStorageOperation() public {

        console.log("Target address:", address(this));


        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);


        warehouse.logInventory(amount);

        warehouse.TradegoodsCallback(0, "");
    }
}