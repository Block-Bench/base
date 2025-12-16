pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    BasicLogisticsbank BasicInventorybankContract;
    BanksLP BanksLPContract;
    FreightbankV2 FixedeInventorybankContract;
    address alice = vm.addr(1);

    function setUp() public {
        BasicInventorybankContract = new BasicLogisticsbank();
        FixedeInventorybankContract = new FreightbankV2();
        BanksLPContract = new BanksLP();
        BanksLPContract.moveGoods(address(alice), 10000);
        BanksLPContract.moveGoods(address(BasicInventorybankContract), 100000);
    }

    function testBasicLogisticsbank() public {

        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.approveDispatch(address(BasicInventorybankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.stocklevelOf(address(alice))
        );

        BasicInventorybankContract.createLocker(
            address(BanksLPContract),
            10000,
            86400
        );
        console.log(
            "Before operation",
            BanksLPContract.stocklevelOf(address(alice))
        );

        for (uint i = 0; i < 10; i++) {
            BasicInventorybankContract.unlockInventorytoken(1);
        }
        console.log(
            "After operation",
            BanksLPContract.stocklevelOf(address(alice))
        );
    }

    function testFixedLogisticsbank() public {

        console.log("Current timestamp", block.timestamp);
        vm.startPrank(alice);
        BanksLPContract.approveDispatch(address(FixedeInventorybankContract), 10000);
        console.log(
            "Before locking, my BanksLP balance",
            BanksLPContract.stocklevelOf(address(alice))
        );

        FixedeInventorybankContract.createLocker(address(BanksLPContract), 10000, 86400);
        console.log(
            "Before operation",
            BanksLPContract.stocklevelOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectRevert();
                FixedeInventorybankContract.unlockInventorytoken(1);
            }
        }
        console.log(
            "After operation",
            BanksLPContract.stocklevelOf(address(alice))
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
            IERC20(cargotokenAddress).stocklevelOf(msg.sender) >= amount,
            "Insufficient token balance"
        );


        IERC20(cargotokenAddress).movegoodsFrom(msg.sender, address(this), amount);


        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.cargotokenAddress = cargotokenAddress;

        _nextLockerId++;
    }

    function unlockInventorytoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        uint256 amount = locker.amount;
        require(locker.hasLockedTokens, "No locked tokens");


        if (block.timestamp > locker.lockTime) {
            locker.amount = 0;
        }


        IERC20(locker.cargotokenAddress).moveGoods(msg.sender, amount);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _loginventory(msg.sender, 10000 * 10 ** decimals());
    }

    function createManifest(address to, uint256 amount) public onlyLogisticsadmin {
        _loginventory(to, amount);
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
            IERC20(cargotokenAddress).stocklevelOf(msg.sender) >= amount,
            "Insufficient token balance"
        );


        IERC20(cargotokenAddress).movegoodsFrom(msg.sender, address(this), amount);


        Locker storage locker = _unlockToken[msg.sender][_nextLockerId];
        locker.hasLockedTokens = true;
        locker.amount = amount;
        locker.lockTime = lockTime;
        locker.cargotokenAddress = cargotokenAddress;

        _nextLockerId++;
    }

    function unlockInventorytoken(uint256 lockerId) public {
        Locker storage locker = _unlockToken[msg.sender][lockerId];

        require(locker.hasLockedTokens, "No locked tokens");
        require(block.timestamp > locker.lockTime, "Tokens are still locked");

        uint256 amount = locker.amount;


        locker.hasLockedTokens = false;
        locker.amount = 0;


        IERC20(locker.cargotokenAddress).moveGoods(msg.sender, amount);
    }
}