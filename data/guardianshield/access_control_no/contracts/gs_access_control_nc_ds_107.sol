pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleVault {
    constructor() {
        owner = msg.sender;
    }

    address public owner;


    function mint(uint256 amountToDeposit) external returns (uint256) {

        address vault = address(this);
        assembly {
            tstore(1, vault)
        }


        this.SwapCallback(amountToDeposit, "");

    }


    function SwapCallback(uint256 amount ,bytes calldata data) external {

        address vault;
        assembly {
            vault := tload(1)
        }


        require(msg.sender == vault, "Not authorized");

        if (vault == address(this)) {

            console.log("vault address:", vault);

            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", vault);
        }
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

contract TransientStorageMisuseTest is Test {
    SimpleVault vault;

    function setUp() public onlyOwner {
        vault = new SimpleVault();
    }

    function testStorageOperation() public {

        console.log("Target address:", address(this));


        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);


        vault.mint(amount);

        vault.SwapCallback(0, "");
    }
}