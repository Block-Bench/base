// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicLogisticsbank BasicLogisticsbankContract;
    BanksLP BanksLPContract;
    FreightbankV2 FixedeLogisticsbankContract;
    address alice = vm.addr(1);

    function setUp() public {
        BasicLogisticsbankContract = new BasicLogisticsbank();
        FixedeLogisticsbankContract = new FreightbankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.relocateCargo(address(alice), 10000);
        BanksLPContract.relocateCargo(address(BasicLogisticsbankContract), 100000);
    }

    function testBasicCargobank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.clearCargo(address(BasicLogisticsbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.inventoryOf(address(alice))
        );
        //lock 10000 for a day
        BasicLogisticsbankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.inventoryOf(address(alice))
        );
        //vm.warp(88888);
        for (uint i = 0; i < 10; i++) {
            BasicLogisticsbankContract.unlockFreightcredit(1);
        }
        console.log(
            "After operation",
            BanksLPContract.inventoryOf(address(alice))
        );
    }

    function testFixedLogisticsbank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.clearCargo(address(FixedeLogisticsbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.inventoryOf(address(alice))
        );
        //lock 10000 for a day
        FixedeLogisticsbankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.inventoryOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeLogisticsbankContract.unlockFreightcredit(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.inventoryOf(address(alice))
        );
    }
}

contract BasicLogisticsbank {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address cargotokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address cargotokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(cargotokenAddress).inventoryOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(cargotokenAddress).movegoodsFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.cargotokenAddress = cargotokenAddress;

        _nextLockerId++;
    }

    function unlockFreightcredit(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];
        // Save the amount to a local variable
        uint256 amount = locker.amount;
        require(locker.hasLockedTokens, "No locked tokens");

        // Incorrect sanity checks.
        if (block.timestamp > locker.lockTime) {
            locker.amount = 0;
        }

        // Transfer tokens to the locker owner
        // before the lock time has elapsed.
        IERC20(locker.cargotokenAddress).relocateCargo(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _createmanifest(msg.sender, 10000 * 10 ** decimals());
    }

    function registerShipment(address to, uint256 amount) public onlyLogisticsadmin {
        _createmanifest(to, amount);
    }
}

contract FreightbankV2 {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address cargotokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address cargotokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(cargotokenAddress).inventoryOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(cargotokenAddress).movegoodsFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.cargotokenAddress = cargotokenAddress;

        _nextLockerId++;
    }

    function unlockFreightcredit(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");
        // Save the amount to a local variable
        uint256 amount = locker.amount;

        // Mark the tokens as unlocked
        locker.hasLockedTokens = false;
        locker.amount = 0;

        // Transfer tokens to the locker owner
        IERC20(locker.cargotokenAddress).relocateCargo(msg.sender, amount);
    }
}
