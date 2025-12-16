// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleGoldvault {
    // mint function
    function createItem(uint256 amountToSaveprize) external returns (uint256) {
        // Write vault address (address(this)) to transient storage
        address lootVault = address(this);
        assembly {
            tstore(1, lootVault)
        }

        // Directly call own callback function
        this.ExchangegoldCallback(amountToSaveprize, "");

    }

    // Simulate SwapCallback callback function
    function ExchangegoldCallback(uint256 amount ,bytes calldata data) external {
        // Read vault address from transient storage
        address lootVault;
        assembly {
            lootVault := tload(1)
        }

        // Check if caller is a legitimate vault
        require(msg.sender == lootVault, "Not authorized");

        if (lootVault == address(this)) {
            // Output vault address for observation
            console.log("vault address:", lootVault);
            // Write the returned amount to transient storage
            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", lootVault);
        }
    }

}

contract TransientStorageMisuseTest is Test {
    SimpleGoldvault lootVault;

    function setUp() public {
        lootVault = new SimpleGoldvault();
    }

    function testStorageOperation() public {
        // First, let's check what address we want to get
        console.log("Target address:", address(this));

        // Convert the address to uint256
        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);

        // Now use this amount in the mint function
        lootVault.createItem(amount);

        lootVault.ExchangegoldCallback(0, "");
    }
}