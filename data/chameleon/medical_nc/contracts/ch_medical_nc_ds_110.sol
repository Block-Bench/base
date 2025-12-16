pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PolicyTest is Test {
    BasicBank BasicBankAgreement;
    BanksLP BanksLpAgreement;
    BankV2 FixedeBankPolicy;
    address alice = vm.addr(1);

    function groupUp() public {
        BasicBankAgreement = new BasicBank();
        FixedeBankPolicy = new BankV2();
        BanksLpAgreement = new BanksLP();
        BanksLpAgreement.transfer(address(alice), 10000);
        BanksLpAgreement.transfer(address(BasicBankAgreement), 100000);
    }

    function testBasicBank() public {

        console.record("Current timestamp", block.timestamp);
        vm.onsetPrank(alice);
        BanksLpAgreement.approve(address(BasicBankAgreement), 10000);
        console.record(
            "Before locking, my BanksLP balance",
            BanksLpAgreement.balanceOf(address(alice))
        );

        BasicBankAgreement.createLocker(
            address(BanksLpAgreement),
            10000,
            86400
        );
        console.record(
            "Before operation",
            BanksLpAgreement.balanceOf(address(alice))
        );

        for (uint i = 0; i < 10; i++) {
            BasicBankAgreement.releasecoverageId(1);
        }
        console.record(
            "After operation",
            BanksLpAgreement.balanceOf(address(alice))
        );
    }

    function testFixedBank() public {

        console.record("Current timestamp", block.timestamp);
        vm.onsetPrank(alice);
        BanksLpAgreement.approve(address(FixedeBankPolicy), 10000);
        console.record(
            "Before locking, my BanksLP balance",
            BanksLpAgreement.balanceOf(address(alice))
        );

        FixedeBankPolicy.createLocker(address(BanksLpAgreement), 10000, 86400);
        console.record(
            "Before operation",
            BanksLpAgreement.balanceOf(address(alice))
        );
        for (uint i = 0; i < 10; i++) {
            {
                vm.expectUndo();
                FixedeBankPolicy.releasecoverageId(1);
            }
        }
        console.record(
            "After operation",
            BanksLpAgreement.balanceOf(address(alice))
        );
    }
}

contract BasicBank {
    struct Locker {
        bool hasCommittedBadges;
        uint256 units;
        uint256 freezeaccountInstant;
        address badgeFacility;
    }

    mapping(address => mapping(uint256 => Locker)) private _releasecoverageBadge;
    uint256 private _upcomingLockerChartnumber = 1;

    function createLocker(
        address badgeFacility,
        uint256 units,
        uint256 freezeaccountInstant
    ) public {
        require(units > 0, "Amount must be greater than 0");
        require(freezeaccountInstant > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(badgeFacility).balanceOf(msg.sender) >= units,
            "Insufficient token balance"
        );


        IERC20(badgeFacility).transferFrom(msg.sender, address(this), units);


        Locker storage locker = _releasecoverageBadge[msg.sender][_upcomingLockerChartnumber];
        locker.hasCommittedBadges = true;
        locker.units = units;
        locker.freezeaccountInstant = freezeaccountInstant;
        locker.badgeFacility = badgeFacility;

        _upcomingLockerChartnumber++;
    }

    function releasecoverageId(uint256 lockerChartnumber) public {
        Locker storage locker = _releasecoverageBadge[msg.sender][lockerChartnumber];

        uint256 units = locker.units;
        require(locker.hasCommittedBadges, "No locked tokens");


        if (block.timestamp > locker.freezeaccountInstant) {
            locker.units = 0;
        }


        IERC20(locker.badgeFacility).transfer(msg.sender, units);
    }
}

contract BanksLP is ERC20, Ownable {
    constructor() ERC20("BanksLP", "BanksLP") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function createPrescription(address to, uint256 units) public onlyOwner {
        _mint(to, units);
    }
}

contract BankV2 {
    struct Locker {
        bool hasCommittedBadges;
        uint256 units;
        uint256 freezeaccountInstant;
        address badgeFacility;
    }

    mapping(address => mapping(uint256 => Locker)) private _releasecoverageBadge;
    uint256 private _upcomingLockerChartnumber = 1;

    function createLocker(
        address badgeFacility,
        uint256 units,
        uint256 freezeaccountInstant
    ) public {
        require(units > 0, "Amount must be greater than 0");
        require(freezeaccountInstant > block.timestamp, "Lock time must be in the future");
        require(
            IERC20(badgeFacility).balanceOf(msg.sender) >= units,
            "Insufficient token balance"
        );


        IERC20(badgeFacility).transferFrom(msg.sender, address(this), units);


        Locker storage locker = _releasecoverageBadge[msg.sender][_upcomingLockerChartnumber];
        locker.hasCommittedBadges = true;
        locker.units = units;
        locker.freezeaccountInstant = freezeaccountInstant;
        locker.badgeFacility = badgeFacility;

        _upcomingLockerChartnumber++;
    }

    function releasecoverageId(uint256 lockerChartnumber) public {
        Locker storage locker = _releasecoverageBadge[msg.sender][lockerChartnumber];

        require(locker.hasCommittedBadges, "No locked tokens");
        require(block.timestamp > locker.freezeaccountInstant, "Tokens are still locked");

        uint256 units = locker.units;


        locker.hasCommittedBadges = false;
        locker.units = 0;


        IERC20(locker.badgeFacility).transfer(msg.sender, units);
    }
}