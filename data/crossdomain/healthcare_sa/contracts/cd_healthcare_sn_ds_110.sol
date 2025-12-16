// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicCoveragebank BasicCoveragebankContract;
    BanksLP BanksLPContract;
    MedicalbankV2 FixedeCoveragebankContract;
    address alice = vm.addr(1);

    function setUp() public {
        BasicCoveragebankContract = new BasicCoveragebank();
        FixedeCoveragebankContract = new MedicalbankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.moveCoverage(address(alice), 10000);
        BanksLPContract.moveCoverage(address(BasicCoveragebankContract), 100000);
    }

    function testBasicBenefitbank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.permitPayout(address(BasicCoveragebankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.coverageOf(address(alice))
        );
        //lock 10000 for a day
        BasicCoveragebankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.coverageOf(address(alice))
        );
        //vm.warp(88888);
        for (uint i = 0; i < 10; i++) {
            BasicCoveragebankContract.unlockMedicalcredit(1);
        }
        console.log(
            "After operation",
            BanksLPContract.coverageOf(address(alice))
        );
    }

    function testFixedCoveragebank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.permitPayout(address(FixedeCoveragebankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.coverageOf(address(alice))
        );
        //lock 10000 for a day
        FixedeCoveragebankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.coverageOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeCoveragebankContract.unlockMedicalcredit(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.coverageOf(address(alice))
        );
    }
}

contract BasicCoveragebank {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address healthtokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address healthtokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(healthtokenAddress).coverageOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(healthtokenAddress).transferbenefitFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.healthtokenAddress = healthtokenAddress;

        _nextLockerId++;
    }

    function unlockMedicalcredit(uint256 lockerId) public {
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
        IERC20(locker.healthtokenAddress).moveCoverage(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _createbenefit(msg.sender, 10000 * 10 ** decimals());
    }

    function issueCoverage(address to, uint256 amount) public onlyManager {
        _createbenefit(to, amount);
    }
}

contract MedicalbankV2 {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address healthtokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address healthtokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(healthtokenAddress).coverageOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(healthtokenAddress).transferbenefitFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.healthtokenAddress = healthtokenAddress;

        _nextLockerId++;
    }

    function unlockMedicalcredit(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");
        // Save the amount to a local variable
        uint256 amount = locker.amount;

        // Mark the tokens as unlocked
        locker.hasLockedTokens = false;
        locker.amount = 0;

        // Transfer tokens to the locker owner
        IERC20(locker.healthtokenAddress).moveCoverage(msg.sender, amount);
    }
}
