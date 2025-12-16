pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleLootvault {

    function craftGear(uint256 amountToCachetreasure) external returns (uint256) {

        address treasureVault = address(this);
        assembly {
            tstore(1, treasureVault)
        }


        this.SwaplootCallback(amountToCachetreasure, "");

    }


    function SwaplootCallback(uint256 amount ,bytes calldata data) external {

        address treasureVault;
        assembly {
            treasureVault := tload(1)
        }


        require(msg.sender == treasureVault, "Not authorized");

        if (treasureVault == address(this)) {

            console.log("vault address:", treasureVault);

            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", treasureVault);
        }
    }

}

contract TransientStorageMisuseTest is Test {
    SimpleLootvault treasureVault;

    function setUp() public {
        treasureVault = new SimpleLootvault();
    }

    function testStorageOperation() public {

        console.log("Target address:", address(this));


        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);


        treasureVault.craftGear(amount);

        treasureVault.SwaplootCallback(0, "");
    }
}