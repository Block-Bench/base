pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicReputationbank BasicTipbankContract;
    BanksLP BanksLPContract;
    SocialbankV2 FixedeTipbankContract;
    address alice = vm.addr(1);

    function setUp() public {
        BasicTipbankContract = new BasicReputationbank();
        FixedeTipbankContract = new SocialbankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.sendTip(address(alice), 10000);
        BanksLPContract.sendTip(address(BasicTipbankContract), 100000);
    }

    function testBasicReputationbank() public {

        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.permitTransfer(address(BasicTipbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.karmaOf(address(alice))
        );

        BasicTipbankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.karmaOf(address(alice))
        );

        for (uint i = 0; i < 10; i++) {
            BasicTipbankContract.unlockReputationtoken(1);
        }
        console.log(
            "After operation",
            BanksLPContract.karmaOf(address(alice))
        );
    }

    function testFixedReputationbank() public {

        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.permitTransfer(address(FixedeTipbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.karmaOf(address(alice))
        );

        FixedeTipbankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.karmaOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeTipbankContract.unlockReputationtoken(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.karmaOf(address(alice))
        );
    }
}

contract BasicReputationbank {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address karmatokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address karmatokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(karmatokenAddress).karmaOf(msg.sender) >= amount,
            "Insufficient token balance"
        );


        IERC20(karmatokenAddress).sendtipFrom(msg.sender, address(this), amount);


        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.karmatokenAddress = karmatokenAddress;

        _nextLockerId++;
    }

    function unlockReputationtoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        uint256 amount = locker.amount;
        require(locker.hasLockedTokens, "No locked tokens");


        if (block.timestamp > locker.lockTime) {
            locker.amount = 0;
        }


        IERC20(locker.karmatokenAddress).sendTip(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _buildinfluence(msg.sender, 10000 * 10 ** decimals());
    }

    function gainReputation(address to, uint256 amount) public onlyCommunitylead {
        _buildinfluence(to, amount);
    }
}

contract SocialbankV2 {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address karmatokenAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address karmatokenAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(karmatokenAddress).karmaOf(msg.sender) >= amount,
            "Insufficient token balance"
        );


        IERC20(karmatokenAddress).sendtipFrom(msg.sender, address(this), amount);


        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.karmatokenAddress = karmatokenAddress;

        _nextLockerId++;
    }

    function unlockReputationtoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");

        uint256 amount = locker.amount;


        locker.hasLockedTokens = false;
        locker.amount = 0;


        IERC20(locker.karmatokenAddress).sendTip(msg.sender, amount);
    }
}