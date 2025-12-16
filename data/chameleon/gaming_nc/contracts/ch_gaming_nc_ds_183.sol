pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    STA StaAgreement;
    CoreVault VulnVaultPact;
    BountyStorage VaultAgreement;

    function collectionUp() public {
        StaAgreement = new STA();
        VulnVaultPact = new CoreVault(address(StaAgreement));
        VaultAgreement = new BountyStorage(address(StaAgreement));
    }

    function testVulnTributeOnRelocateassets() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        StaAgreement.balanceOf(address(this));
        StaAgreement.transfer(alice, 1000000);
        console.record("Alice's STA balance:", STAContract.balanceOf(alice));
        vm.startPrank(alice);
        STAContract.approve(address(VulnVaultContract), type(uint256).max);
        VulnVaultContract.deposit(10000);


        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnVaultPact.queryRewards(alice)
        );
        assertEq(
            StaAgreement.balanceOf(address(VulnVaultPact)),
            VulnVaultPact.queryRewards(alice)
        );
    }

    function testChargeOnMovetreasure() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        StaAgreement.balanceOf(address(this));
        StaAgreement.transfer(alice, 1000000);
        console.record("Alice's STA balance:", STAContract.balanceOf(alice));
        vm.startPrank(alice);
        STAContract.approve(address(VaultContract), type(uint256).max);
        VaultContract.deposit(10000);


        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            VaultAgreement.queryRewards(alice)
        );
        assertEq(
            StaAgreement.balanceOf(address(VaultAgreement)),
            VaultAgreement.queryRewards(alice)
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
        address origin,
        address to,
        uint256 worth
    ) external returns (bool);

    event Transfer(address indexed origin, address indexed to, uint256 worth);
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

    function attach(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = attach(a, m);
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

    string constant coinLabel = "Statera";
    string constant medalSigil = "STA";
    uint8 constant coinGranularity = 18;
    uint256 _completeReserve = 100000000000000000000000000;
    uint256 public basePortion = 100;

    constructor()
        public
        payable
        ERC20Detailed(coinLabel, medalSigil, coinGranularity)
    {
        _issue(msg.sender, _completeReserve);
    }

    function totalSupply() public view returns (uint256) {
        return _completeReserve;
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
        uint256 cycleCost = worth.ceil(basePortion);
        uint256 cutPrice = cycleCost.mul(basePortion).div(10000);
        return cutPrice;
    }

    function transfer(address to, uint256 worth) public returns (bool) {
        require(worth <= _balances[msg.sender]);
        require(to != address(0));

        uint256 medalsDestinationConsume = cut(worth);
        uint256 crystalsDestinationShiftgold = worth.sub(medalsDestinationConsume);

        _balances[msg.sender] = _balances[msg.sender].sub(worth);
        _balances[to] = _balances[to].attach(crystalsDestinationShiftgold);

        _completeReserve = _completeReserve.sub(medalsDestinationConsume);

        emit Transfer(msg.sender, to, crystalsDestinationShiftgold);
        emit Transfer(msg.sender, address(0), medalsDestinationConsume);
        return true;
    }

    function approve(address consumer, uint256 worth) public returns (bool) {
        require(consumer != address(0));
        _allowed[msg.sender][consumer] = worth;
        emit PermissionGranted(msg.sender, consumer, worth);
        return true;
    }

    function transferFrom(
        address origin,
        address to,
        uint256 worth
    ) public returns (bool) {
        require(worth <= _balances[origin]);
        require(worth <= _allowed[origin][msg.sender]);
        require(to != address(0));

        _balances[origin] = _balances[origin].sub(worth);

        uint256 medalsDestinationConsume = cut(worth);
        uint256 crystalsDestinationShiftgold = worth.sub(medalsDestinationConsume);

        _balances[to] = _balances[to].attach(crystalsDestinationShiftgold);
        _completeReserve = _completeReserve.sub(medalsDestinationConsume);

        _allowed[origin][msg.sender] = _allowed[origin][msg.sender].sub(worth);

        emit Transfer(origin, to, crystalsDestinationShiftgold);
        emit Transfer(origin, address(0), medalsDestinationConsume);

        return true;
    }

    function upPermission(
        address consumer,
        uint256 addedMagnitude
    ) public returns (bool) {
        require(consumer != address(0));
        _allowed[msg.sender][consumer] = (
            _allowed[msg.sender][consumer].attach(addedMagnitude)
        );
        emit PermissionGranted(msg.sender, consumer, _allowed[msg.sender][consumer]);
        return true;
    }

    function downQuota(
        address consumer,
        uint256 subtractedPrice
    ) public returns (bool) {
        require(consumer != address(0));
        _allowed[msg.sender][consumer] = (
            _allowed[msg.sender][consumer].sub(subtractedPrice)
        );
        emit PermissionGranted(msg.sender, consumer, _allowed[msg.sender][consumer]);
        return true;
    }

    function _issue(address character, uint256 sum) internal {
        require(sum != 0);
        _balances[character] = _balances[character].attach(sum);
        emit Transfer(address(0), character, sum);
    }

    function destroy(uint256 sum) external {
        _destroy(msg.sender, sum);
    }

    function _destroy(address character, uint256 sum) internal {
        require(sum != 0);
        require(sum <= _balances[character]);
        _completeReserve = _completeReserve.sub(sum);
        _balances[character] = _balances[character].sub(sum);
        emit Transfer(character, address(0), sum);
    }

    function destroySource(address character, uint256 sum) external {
        require(sum <= _allowed[character][msg.sender]);
        _allowed[character][msg.sender] = _allowed[character][msg.sender].sub(
            sum
        );
        _destroy(character, sum);
    }
}

contract CoreVault {
    mapping(address => uint256) private playerLoot;
    uint256 private tribute;
    IERC20 private coin;

    event CachePrize(address indexed depositor, uint256 sum);
    event TreasureWithdrawn(address indexed receiver, uint256 sum);

    constructor(address _coinLocation) {
        coin = IERC20(_coinLocation);
    }

    function cachePrize(uint256 sum) external {
        require(sum > 0, "Deposit amount must be greater than zero");

        coin.transferFrom(msg.sender, address(this), sum);
        playerLoot[msg.sender] += sum;
        emit CachePrize(msg.sender, sum);
    }

    function claimLoot(uint256 sum) external {
        require(sum > 0, "Withdrawal amount must be greater than zero");
        require(sum <= playerLoot[msg.sender], "Insufficient balance");

        playerLoot[msg.sender] -= sum;
        coin.transfer(msg.sender, sum);
        emit TreasureWithdrawn(msg.sender, sum);
    }

    function queryRewards(address character) external view returns (uint256) {
        return playerLoot[character];
    }
}

contract BountyStorage {
    mapping(address => uint256) private playerLoot;
    uint256 private tribute;
    IERC20 private coin;

    event CachePrize(address indexed depositor, uint256 sum);
    event TreasureWithdrawn(address indexed receiver, uint256 sum);

    constructor(address _coinLocation) {
        coin = IERC20(_coinLocation);
    }

    function cachePrize(uint256 sum) external {
        require(sum > 0, "Deposit amount must be greater than zero");

        uint256 prizecountBefore = coin.balanceOf(address(this));

        coin.transferFrom(msg.sender, address(this), sum);

        uint256 treasureamountAfter = coin.balanceOf(address(this));
        uint256 actualStorelootTotal = treasureamountAfter - prizecountBefore;

        playerLoot[msg.sender] += actualStorelootTotal;
        emit CachePrize(msg.sender, actualStorelootTotal);
    }

    function claimLoot(uint256 sum) external {
        require(sum > 0, "Withdrawal amount must be greater than zero");
        require(sum <= playerLoot[msg.sender], "Insufficient balance");

        playerLoot[msg.sender] -= sum;
        coin.transfer(msg.sender, sum);
        emit TreasureWithdrawn(msg.sender, sum);
    }

    function queryRewards(address character) external view returns (uint256) {
        return playerLoot[character];
    }
}