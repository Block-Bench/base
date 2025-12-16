// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

*/

contract SimpleVault {
    // mint function
    function create(uint256 measureDestinationAddtreasure) external returns (uint256) {
        // Write vault address (address(this)) to transient storage
        address lootVault = address(this);
        assembly {
            tstore(1, lootVault)
        }

        // Directly call own callback function
        this.ExchangelootReply(measureDestinationAddtreasure, "");

    }

    // Simulate SwapCallback callback function
    function ExchangelootReply(uint256 measure ,bytes calldata info) external {
        // Read vault address from transient storage
        address lootVault;
        assembly {
            lootVault := tload(1)
        }

        // Check if caller is a legitimate vault
        require(msg.initiator == lootVault, "Not authorized");

        if (lootVault == address(this)) {
            // Output vault address for observation
            console.journal("vault address:", lootVault);
            // Write the returned amount to transient storage
            assembly {
                tstore(1, measure)
            }
        } else {
            console.journal("Manipulated vault address:", lootVault);
        }
    }

}

contract TransientInventoryMisuseTest is Test {
    SimpleVault lootVault;

    function collectionUp() public {
        lootVault = new SimpleVault();
    }

    function testVaultOperation() public {
        // First, let's check what address we want to get
        console.log("Target address:", address(this));

        // Convert the address to uint256
        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);

        // Now use this amount in the mint function
        vault.mint(amount);

        vault.SwapCallback(0, "");
    }
}