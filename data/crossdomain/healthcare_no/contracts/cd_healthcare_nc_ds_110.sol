pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicCoveragebank BasicHealthbankContract;
    BanksLP BanksLPContract;
    MedicalbankV2 FixedeHealthbankContract;
    address alice = vm.addr(1);

    function setUp() public {
        BasicHealthbankContract = new BasicCoveragebank();
        FixedeHealthbankContract = new MedicalbankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.transferBenefit(address(alice), 10000);
        BanksLPContract.transferBenefit(address(BasicHealthbankContract), 100000);
    }

    function testBasicCoveragebank() public {

        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.validateClaim(address(BasicHealthbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.benefitsOf(address(alice))
        );

        BasicHealthbankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.benefitsOf(address(alice))
        );

        for (uint i = 0; i < 10; i++) {
            BasicHealthbankContract.unlockCoveragetoken(1);
        }
        console.log(
            "After operation",
            BanksLPContract.benefitsOf(address(alice))
        );
    }

    function testFixedCoveragebank() public {

        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.validateClaim(address(FixedeHealthbankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.benefitsOf(address(alice))
        );

        FixedeHealthbankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.benefitsOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeHealthbankContract.unlockCoveragetoken(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.benefitsOf(address(alice))
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
            IERC20(healthtokenAddress).benefitsOf(msg.sender) >= amount,
            "Insufficient token balance"
        );


        IERC20(healthtokenAddress).transferbenefitFrom(msg.sender, address(this), amount);


        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.healthtokenAddress = healthtokenAddress;

        _nextLockerId++;
    }

    function unlockCoveragetoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        uint256 amount = locker.amount;
        require(locker.hasLockedTokens, "No locked tokens");


        if (block.timestamp > locker.lockTime) {
            locker.amount = 0;
        }


        IERC20(locker.healthtokenAddress).transferBenefit(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _generatecredit(msg.sender, 10000 * 10 ** decimals());
    }

    function createBenefit(address to, uint256 amount) public onlySupervisor {
        _generatecredit(to, amount);
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
            IERC20(healthtokenAddress).benefitsOf(msg.sender) >= amount,
            "Insufficient token balance"
        );


        IERC20(healthtokenAddress).transferbenefitFrom(msg.sender, address(this), amount);


        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.healthtokenAddress = healthtokenAddress;

        _nextLockerId++;
    }

    function unlockCoveragetoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");

        uint256 amount = locker.amount;


        locker.hasLockedTokens = false;
        locker.amount = 0;


        IERC20(locker.healthtokenAddress).transferBenefit(msg.sender, amount);
    }
}