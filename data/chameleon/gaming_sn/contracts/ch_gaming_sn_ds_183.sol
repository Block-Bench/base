// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    STA StaAgreement;
    CoreVault VulnVaultPact;
    BountyStorage VaultPact;

    function groupUp() public {
        StaAgreement = new STA();
        VulnVaultPact = new CoreVault(address(StaAgreement));
        VaultPact = new BountyStorage(address(StaAgreement));
    }

    function testVulnChargeOnShiftgold() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        StaAgreement.balanceOf(address(this));
        StaAgreement.transfer(alice, 1000000);
        console.record("Alice's STA balance:", STAContract.balanceOf(alice)); // charge 1% fee
        vm.startPrank(alice);
        STAContract.approve(address(VulnVaultContract), type(uint256).max);
        VulnVaultContract.deposit(10000);
        //VulnVaultContract.getBalance(alice);

        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnVaultPact.viewTreasure(alice)
        ); // charge 1% fee
        assertEq(
            StaAgreement.balanceOf(address(VulnVaultPact)),
            VulnVaultPact.viewTreasure(alice)
        );
    }

    function testTributeOnTradefunds() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        StaAgreement.balanceOf(address(this));
        StaAgreement.transfer(alice, 1000000);
        console.record("Alice's STA balance:", STAContract.balanceOf(alice)); // charge 1% fee
        vm.startPrank(alice);
        STAContract.approve(address(VaultContract), type(uint256).max);
        VaultContract.deposit(10000);
        //VaultContract.getBalance(alice);

        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            VaultPact.viewTreasure(alice)
        ); // charge 1% fee
        assertEq(
            StaAgreement.balanceOf(address(VaultPact)),
            VaultPact.viewTreasure(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(
        address owner,
        address consumer
    ) external view returns (uint256);

    function transfer(address to, uint256 worth) external returns (bool);

    function approve(address consumer, uint256 worth) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 worth
    ) external returns (bool);

    event Transfer(address indexed source, address indexed to, uint256 worth);
    event PermissionGranted(
        address indexed owner,
        address indexed consumer,
        uint256 worth
    );
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function insert(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = insert(a, m);
        uint256 d = sub(c, 1);
        return mul(div(d, m), m);
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract STA is ERC20Detailed {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    string constant gemTitle = "Statera";
    string constant gemIcon = "STA";
    uint8 constant coinGranularity = 18;
    uint256 _combinedStock = 100000000000000000000000000;
    uint256 public basePortion = 100;

    constructor()
        public
        payable
        ERC20Detailed(gemTitle, gemIcon, coinGranularity)
    {
        _issue(msg.sender, _combinedStock);
    }

    function totalSupply() public view returns (uint256) {
        return _combinedStock;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(
        address owner,
        address consumer
    ) public view returns (uint256) {
        return _allowed[owner][consumer];
    }

    function cut(uint256 worth) public view returns (uint256) {
        uint256 wavePrice = worth.ceil(basePortion);
        uint256 cutMagnitude = wavePrice.mul(basePortion).div(10000);
        return cutMagnitude;
    }

    function transfer(address to, uint256 worth) public returns (bool) {
        require(worth <= _balances[msg.sender]);
        require(to != address(0));

        uint256 coinsTargetIncinerate = cut(worth);
        uint256 crystalsDestinationTradefunds = worth.sub(coinsTargetIncinerate);

        _balances[msg.sender] = _balances[msg.sender].sub(worth);
        _balances[to] = _balances[to].insert(crystalsDestinationTradefunds);

        _combinedStock = _combinedStock.sub(coinsTargetIncinerate);

        emit Transfer(msg.sender, to, crystalsDestinationTradefunds);
        emit Transfer(msg.sender, address(0), coinsTargetIncinerate);
        return true;
    }

    function approve(address consumer, uint256 worth) public returns (bool) {
        require(consumer != address(0));
        _allowed[msg.sender][consumer] = worth;
        emit PermissionGranted(msg.sender, consumer, worth);
        return true;
    }

    function transferFrom(
        address source,
        address to,
        uint256 worth
    ) public returns (bool) {
        require(worth <= _balances[source]);
        require(worth <= _allowed[source][msg.sender]);
        require(to != address(0));

        _balances[source] = _balances[source].sub(worth);

        uint256 coinsTargetIncinerate = cut(worth);
        uint256 crystalsDestinationTradefunds = worth.sub(coinsTargetIncinerate);

        _balances[to] = _balances[to].insert(crystalsDestinationTradefunds);
        _combinedStock = _combinedStock.sub(coinsTargetIncinerate);

        _allowed[source][msg.sender] = _allowed[source][msg.sender].sub(worth);

        emit Transfer(source, to, crystalsDestinationTradefunds);
        emit Transfer(source, address(0), coinsTargetIncinerate);

        return true;
    }

    function upPermission(
        address consumer,
        uint256 addedWorth
    ) public returns (bool) {
        require(consumer != address(0));
        _allowed[msg.sender][consumer] = (
            _allowed[msg.sender][consumer].insert(addedWorth)
        );
        emit PermissionGranted(msg.sender, consumer, _allowed[msg.sender][consumer]);
        return true;
    }

    function downPermission(
        address consumer,
        uint256 subtractedCost
    ) public returns (bool) {
        require(consumer != address(0));
        _allowed[msg.sender][consumer] = (
            _allowed[msg.sender][consumer].sub(subtractedCost)
        );
        emit PermissionGranted(msg.sender, consumer, _allowed[msg.sender][consumer]);
        return true;
    }

    function _issue(address profile, uint256 measure) internal {
        require(measure != 0);
        _balances[profile] = _balances[profile].insert(measure);
        emit Transfer(address(0), profile, measure);
    }

    function destroy(uint256 measure) external {
        _destroy(msg.sender, measure);
    }

    function _destroy(address profile, uint256 measure) internal {
        require(measure != 0);
        require(measure <= _balances[profile]);
        _combinedStock = _combinedStock.sub(measure);
        _balances[profile] = _balances[profile].sub(measure);
        emit Transfer(profile, address(0), measure);
    }

    function destroySource(address profile, uint256 measure) external {
        require(measure <= _allowed[profile][msg.sender]);
        _allowed[profile][msg.sender] = _allowed[profile][msg.sender].sub(
            measure
        );
        _destroy(profile, measure);
    }
}

contract CoreVault {
    mapping(address => uint256) private playerLoot;
    uint256 private charge;
    IERC20 private coin;

    event CachePrize(address indexed depositor, uint256 measure);
    event LootClaimed(address indexed receiver, uint256 measure);

    constructor(address _medalRealm) {
        coin = IERC20(_medalRealm);
    }

    function cachePrize(uint256 measure) external {
        require(measure > 0, "Deposit amount must be greater than zero");

        coin.transferFrom(msg.sender, address(this), measure);
        playerLoot[msg.sender] += measure;
        emit CachePrize(msg.sender, measure);
    }

    function obtainPrize(uint256 measure) external {
        require(measure > 0, "Withdrawal amount must be greater than zero");
        require(measure <= playerLoot[msg.sender], "Insufficient balance");

        playerLoot[msg.sender] -= measure;
        coin.transfer(msg.sender, measure);
        emit LootClaimed(msg.sender, measure);
    }

    function viewTreasure(address profile) external view returns (uint256) {
        return playerLoot[profile];
    }
}

contract BountyStorage {
    mapping(address => uint256) private playerLoot;
    uint256 private charge;
    IERC20 private coin;

    event CachePrize(address indexed depositor, uint256 measure);
    event LootClaimed(address indexed receiver, uint256 measure);

    constructor(address _medalRealm) {
        coin = IERC20(_medalRealm);
    }

    function cachePrize(uint256 measure) external {
        require(measure > 0, "Deposit amount must be greater than zero");

        uint256 prizecountBefore = coin.balanceOf(address(this));

        coin.transferFrom(msg.sender, address(this), measure);

        uint256 treasureamountAfter = coin.balanceOf(address(this));
        uint256 actualStashrewardsCount = treasureamountAfter - prizecountBefore;

        playerLoot[msg.sender] += actualStashrewardsCount;
        emit CachePrize(msg.sender, actualStashrewardsCount);
    }

    function obtainPrize(uint256 measure) external {
        require(measure > 0, "Withdrawal amount must be greater than zero");
        require(measure <= playerLoot[msg.sender], "Insufficient balance");

        playerLoot[msg.sender] -= measure;
        coin.transfer(msg.sender, measure);
        emit LootClaimed(msg.sender, measure);
    }

    function viewTreasure(address profile) external view returns (uint256) {
        return playerLoot[profile];
    }
}
