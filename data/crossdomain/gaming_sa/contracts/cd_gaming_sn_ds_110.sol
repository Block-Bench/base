// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicTreasurebank BasicTreasurebankContract;
    BanksLP BanksLPContract;
    QuestbankV2 FixedeTreasurebankContract;
    address alice = vm.addr(1);

    function setUp() public {
        BasicTreasurebankContract = new BasicTreasurebank();
        FixedeTreasurebankContract = new QuestbankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.giveItems(address(alice), 10000);
        BanksLPContract.giveItems(address(BasicTreasurebankContract), 100000);
    }

    function testBasicItembank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.authorizeDeal(address(BasicTreasurebankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.treasurecountOf(address(alice))
        );
        //lock 10000 for a day
        BasicTreasurebankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.treasurecountOf(address(alice))
        );
        //vm.warp(88888);
        for (uint i = 0; i < 10; i++) {
            BasicTreasurebankContract.unlockGamecoin(1);
        }
        console.log(
            "After operation",
            BanksLPContract.treasurecountOf(address(alice))
        );
    }

    function testFixedQuestbank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.authorizeDeal(address(FixedeTreasurebankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.treasurecountOf(address(alice))
        );
        //lock 10000 for a day
        FixedeTreasurebankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.treasurecountOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeTreasurebankContract.unlockGamecoin(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.treasurecountOf(address(alice))
        );
    }
}

contract BasicTreasurebank {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address questtokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address questtokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(questtokenAddress).treasurecountOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(questtokenAddress).sendgoldFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.questtokenAddress = questtokenAddress;

        _nextLockerId++;
    }

    function unlockGamecoin(uint256 lockerId) public {
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
        IERC20(locker.questtokenAddress).giveItems(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _createitem(msg.sender, 10000 * 10 ** decimals());
    }

    function forgeWeapon(address to, uint256 amount) public onlyGamemaster {
        _createitem(to, amount);
    }
}

contract QuestbankV2 {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address questtokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address questtokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(questtokenAddress).treasurecountOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(questtokenAddress).sendgoldFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.questtokenAddress = questtokenAddress;

        _nextLockerId++;
    }

    function unlockGamecoin(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");
        // Save the amount to a local variable
        uint256 amount = locker.amount;

        // Mark the tokens as unlocked
        locker.hasLockedTokens = false;
        locker.amount = 0;

        // Transfer tokens to the locker owner
        IERC20(locker.questtokenAddress).giveItems(msg.sender, amount);
    }
}
