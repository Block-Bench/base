// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicBank BasicBankContract;
    BanksLP BanksLPContract;
    BankV2 FixedeBankContract;
    address alice = vm.addr(1);

    function setUp() public {
        _doSetUpHandler();
    }

    function _doSetUpHandler() internal {
        BasicBankContract = new BasicBank();
        FixedeBankContract = new BankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.transfer(address(alice), 10000);
        BanksLPContract.transfer(address(BasicBankContract), 100000);
    }

    function testBasicBank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.approve(address(BasicBankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.balanceOf(address(alice))
        );
        //lock 10000 for a day
        BasicBankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.balanceOf(address(alice))
        );
        //vm.warp(88888);
        for (uint i = 0; i < 10; i++) {
            BasicBankContract.unlockToken(1);
        }
        console.log(
            "After operation",
            BanksLPContract.balanceOf(address(alice))
        );
    }

    function testFixedBank() public {
        //In foundry, default timestamp is 1.
        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.approve(address(FixedeBankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.balanceOf(address(alice))
        );
        //lock 10000 for a day
        FixedeBankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.balanceOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeBankContract.unlockToken(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.balanceOf(address(alice))
        );
    }
}

contract BasicBank {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address tokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address tokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.tokenAddress = tokenAddress;

        _nextLockerId++;
    }

    function unlockToken(uint256 lockerId) public {
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
        IERC20(locker.tokenAddress).transfer(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract BankV2 {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address tokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address tokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        // Transfer the tokens to this contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        // Create the locker
        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.tokenAddress = tokenAddress;

        _nextLockerId++;
    }

    function unlockToken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");
        // Save the amount to a local variable
        uint256 amount = locker.amount;

        // Mark the tokens as unlocked
        locker.hasLockedTokens = false;
        locker.amount = 0;

        // Transfer tokens to the locker owner
        IERC20(locker.tokenAddress).transfer(msg.sender, amount);
    }
}
