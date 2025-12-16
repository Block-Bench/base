pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicTreasurebank BasicGoldbankContract;
    BanksLP BanksLPContract;
    QuestbankV2 FixedeGoldbankContract;
    address alice = vm.addr(1);

    function setUp() public {
        BasicGoldbankContract = new BasicTreasurebank();
        FixedeGoldbankContract = new QuestbankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.sendGold(address(alice), 10000);
        BanksLPContract.sendGold(address(BasicGoldbankContract), 100000);
    }

    function testBasicTreasurebank() public {

        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.allowTransfer(address(BasicGoldbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.goldholdingOf(address(alice))
        );

        BasicGoldbankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.goldholdingOf(address(alice))
        );

        for (uint i = 0; i < 10; i++) {
            BasicGoldbankContract.unlockGoldtoken(1);
        }
        console.log(
            "After operation",
            BanksLPContract.goldholdingOf(address(alice))
        );
    }

    function testFixedTreasurebank() public {

        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.allowTransfer(address(FixedeGoldbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.goldholdingOf(address(alice))
        );

        FixedeGoldbankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.goldholdingOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeGoldbankContract.unlockGoldtoken(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.goldholdingOf(address(alice))
        );
    }
}

contract BasicTreasurebank {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address gamecoinAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address gamecoinAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(gamecoinAddress).goldholdingOf(msg.sender) >= amount,
            "Insufficient token balance"
        );


        IERC20(gamecoinAddress).sendgoldFrom(msg.sender, address(this), amount);


        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.gamecoinAddress = gamecoinAddress;

        _nextLockerId++;
    }

    function unlockGoldtoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        uint256 amount = locker.amount;
        require(locker.hasLockedTokens, "No locked tokens");


        if (block.timestamp > locker.lockTime) {
            locker.amount = 0;
        }


        IERC20(locker.gamecoinAddress).sendGold(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _craftgear(msg.sender, 10000 * 10 ** decimals());
    }

    function forgeWeapon(address to, uint256 amount) public onlyGuildleader {
        _craftgear(to, amount);
    }
}

contract QuestbankV2 {
    struct Locker {
        bool hasLockedTokens;
        uint256 amount;
        uint256 lockTime;
        address gamecoinAddress;
    }

    mapping(address => mapping(uint256 => Locker)) private _unlockToken;
    uint256 private _nextLockerId = 1;

    function createLocker(
        address gamecoinAddress,
        uint256 amount,
        uint256 lockTime
    ) public {
        require(amount > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(gamecoinAddress).goldholdingOf(msg.sender) >= amount,
            "Insufficient token balance"
        );


        IERC20(gamecoinAddress).sendgoldFrom(msg.sender, address(this), amount);


        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.gamecoinAddress = gamecoinAddress;

        _nextLockerId++;
    }

    function unlockGoldtoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");

        uint256 amount = locker.amount;


        locker.hasLockedTokens = false;
        locker.amount = 0;


        IERC20(locker.gamecoinAddress).sendGold(msg.sender, amount);
    }
}