// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicReputationbank BasicReputationbankContract;
    BanksLP BanksLPContract;
    SocialbankV2 FixedeReputationbankContract;
    address alice = vm.addr(1);

    function setUp() public {
        BasicReputationbankContract = new BasicReputationbank();
        FixedeReputationbankContract = new SocialbankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.shareKarma(address(alice), 10000);
        BanksLPContract.shareKarma(address(BasicReputationbankContract), 100000);
    }

    function testBasicKarmabank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.authorizeGift(address(BasicReputationbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.influenceOf(address(alice))
        );
        //lock 10000 for a day
        BasicReputationbankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.influenceOf(address(alice))
        );
        //vm.warp(88888);
        for (uint i = 0; i < 10; i++) {
            BasicReputationbankContract.unlockKarmatoken(1);
        }
        console.log(
            "After operation",
            BanksLPContract.influenceOf(address(alice))
        );
    }

    function testFixedSocialbank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.authorizeGift(address(FixedeReputationbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.influenceOf(address(alice))
        );
        //lock 10000 for a day
        FixedeReputationbankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.influenceOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeReputationbankContract.unlockKarmatoken(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.influenceOf(address(alice))
        );
    }
}

contract BasicReputationbank {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address socialtokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address socialtokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(socialtokenAddress).influenceOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(socialtokenAddress).sendtipFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.socialtokenAddress = socialtokenAddress;

        _nextLockerId++;
    }

    function unlockKarmatoken(uint256 lockerId) public {
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
        IERC20(locker.socialtokenAddress).shareKarma(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _earnkarma(msg.sender, 10000 * 10 ** decimals());
    }

    function gainReputation(address to, uint256 amount) public onlyModerator {
        _earnkarma(to, amount);
    }
}

contract SocialbankV2 {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address socialtokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address socialtokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(socialtokenAddress).influenceOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(socialtokenAddress).sendtipFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.socialtokenAddress = socialtokenAddress;

        _nextLockerId++;
    }

    function unlockKarmatoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");
        // Save the amount to a local variable
        uint256 amount = locker.amount;

        // Mark the tokens as unlocked
        locker.hasLockedTokens = false;
        locker.amount = 0;

        // Transfer tokens to the locker owner
        IERC20(locker.socialtokenAddress).shareKarma(msg.sender, amount);
    }
}
