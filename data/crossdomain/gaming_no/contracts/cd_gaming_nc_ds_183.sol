pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    STA STAContract;
    CoreGoldvault VulnLootvaultContract;
    LootVault LootvaultContract;

    function setUp() public {
        STAContract = new STA();
        VulnLootvaultContract = new CoreGoldvault(address(STAContract));
        LootvaultContract = new LootVault(address(STAContract));
    }

    function testVulnRakeOnSharetreasure() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.treasurecountOf(address(this));
        STAContract.giveItems(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.treasurecountOf(alice));
        vm.startPrank(alice);
        STAContract.allowTransfer(address(VulnLootvaultContract), type(uint256).max);
        VulnLootvaultContract.stashItems(10000);


        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnLootvaultContract.getGemtotal(alice)
        );
        assertEq(
            STAContract.treasurecountOf(address(VulnLootvaultContract)),
            VulnLootvaultContract.getGemtotal(alice)
        );
    }

    function testRakeOnSendgold() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.treasurecountOf(address(this));
        STAContract.giveItems(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.treasurecountOf(alice));
        vm.startPrank(alice);
        STAContract.allowTransfer(address(LootvaultContract), type(uint256).max);
        LootvaultContract.stashItems(10000);


        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            LootvaultContract.getGemtotal(alice)
        );
        assertEq(
            STAContract.treasurecountOf(address(LootvaultContract)),
            LootvaultContract.getGemtotal(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function allTreasure() external view returns (uint256);

    function treasurecountOf(address who) external view returns (uint256);

    function allowance(
        address guildLeader,
        address spender
    ) external view returns (uint256);

    function giveItems(address to, uint256 value) external returns (bool);

    function allowTransfer(address spender, uint256 value) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event ShareTreasure(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed guildLeader,
        address indexed spender,
        uint256 value
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a, m);
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

    string constant gamecoinName = "Statera";
    string constant realmcoinSymbol = "STA";
    uint8 constant goldtokenDecimals = 18;
    uint256 _combinedloot = 100000000000000000000000000;
    uint256 public basePercent = 100;

    constructor()
        public
        payable
        ERC20Detailed(gamecoinName, realmcoinSymbol, goldtokenDecimals)
    {
        _issue(msg.sender, _combinedloot);
    }

    function allTreasure() public view returns (uint256) {
        return _combinedloot;
    }

    function treasurecountOf(address guildLeader) public view returns (uint256) {
        return _balances[guildLeader];
    }

    function allowance(
        address guildLeader,
        address spender
    ) public view returns (uint256) {
        return _allowed[guildLeader][spender];
    }

    function cut(uint256 value) public view returns (uint256) {
        uint256 roundValue = value.ceil(basePercent);
        uint256 cutValue = roundValue.mul(basePercent).div(10000);
        return cutValue;
    }

    function giveItems(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToDestroyitem = cut(value);
        uint256 tokensToSharetreasure = value.sub(tokensToDestroyitem);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToSharetreasure);

        _combinedloot = _combinedloot.sub(tokensToDestroyitem);

        emit ShareTreasure(msg.sender, to, tokensToSharetreasure);
        emit ShareTreasure(msg.sender, address(0), tokensToDestroyitem);
        return true;
    }

    function allowTransfer(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function giveitemsFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToDestroyitem = cut(value);
        uint256 tokensToSharetreasure = value.sub(tokensToDestroyitem);

        _balances[to] = _balances[to].add(tokensToSharetreasure);
        _combinedloot = _combinedloot.sub(tokensToDestroyitem);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit ShareTreasure(from, to, tokensToSharetreasure);
        emit ShareTreasure(from, address(0), tokensToDestroyitem);

        return true;
    }

    function upAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].add(addedValue)
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function downAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].sub(subtractedValue)
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _issue(address heroRecord, uint256 amount) internal {
        require(amount != 0);
        _balances[heroRecord] = _balances[heroRecord].add(amount);
        emit ShareTreasure(address(0), heroRecord, amount);
    }

    function destroy(uint256 amount) external {
        _destroy(msg.sender, amount);
    }

    function _destroy(address heroRecord, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[heroRecord]);
        _combinedloot = _combinedloot.sub(amount);
        _balances[heroRecord] = _balances[heroRecord].sub(amount);
        emit ShareTreasure(heroRecord, address(0), amount);
    }

    function destroyFrom(address heroRecord, uint256 amount) external {
        require(amount <= _allowed[heroRecord][msg.sender]);
        _allowed[heroRecord][msg.sender] = _allowed[heroRecord][msg.sender].sub(
            amount
        );
        _destroy(heroRecord, amount);
    }
}

contract CoreGoldvault {
    mapping(address => uint256) private balances;
    uint256 private cut;
    IERC20 private goldToken;

    event CacheTreasure(address indexed contributor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        goldToken = IERC20(_tokenAddress);
    }

    function stashItems(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        goldToken.giveitemsFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit CacheTreasure(msg.sender, amount);
    }

    function retrieveItems(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        goldToken.giveItems(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getGemtotal(address heroRecord) external view returns (uint256) {
        return balances[heroRecord];
    }
}

contract LootVault {
    mapping(address => uint256) private balances;
    uint256 private cut;
    IERC20 private goldToken;

    event CacheTreasure(address indexed contributor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        goldToken = IERC20(_tokenAddress);
    }

    function stashItems(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        uint256 itemcountBefore = goldToken.treasurecountOf(address(this));

        goldToken.giveitemsFrom(msg.sender, address(this), amount);

        uint256 goldholdingAfter = goldToken.treasurecountOf(address(this));
        uint256 actualCachetreasureAmount = goldholdingAfter - itemcountBefore;

        balances[msg.sender] += actualCachetreasureAmount;
        emit CacheTreasure(msg.sender, actualCachetreasureAmount);
    }

    function retrieveItems(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        goldToken.giveItems(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getGemtotal(address heroRecord) external view returns (uint256) {
        return balances[heroRecord];
    }
}