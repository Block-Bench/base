pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    STA STAContract;
    CoreCommunityvault VulnCreatorvaultContract;
    CreatorVault CreatorvaultContract;

    function setUp() public {
        STAContract = new STA();
        VulnCreatorvaultContract = new CoreCommunityvault(address(STAContract));
        CreatorvaultContract = new CreatorVault(address(STAContract));
    }

    function testVulnCreatorcutOnPassinfluence() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.influenceOf(address(this));
        STAContract.shareKarma(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.influenceOf(alice));
        vm.startPrank(alice);
        STAContract.permitTransfer(address(VulnCreatorvaultContract), type(uint256).max);
        VulnCreatorvaultContract.fund(10000);


        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnCreatorvaultContract.getStanding(alice)
        );
        assertEq(
            STAContract.influenceOf(address(VulnCreatorvaultContract)),
            VulnCreatorvaultContract.getStanding(alice)
        );
    }

    function testCreatorcutOnSendtip() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.influenceOf(address(this));
        STAContract.shareKarma(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.influenceOf(alice));
        vm.startPrank(alice);
        STAContract.permitTransfer(address(CreatorvaultContract), type(uint256).max);
        CreatorvaultContract.fund(10000);


        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            CreatorvaultContract.getStanding(alice)
        );
        assertEq(
            STAContract.influenceOf(address(CreatorvaultContract)),
            CreatorvaultContract.getStanding(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function communityReputation() external view returns (uint256);

    function influenceOf(address who) external view returns (uint256);

    function allowance(
        address communityLead,
        address spender
    ) external view returns (uint256);

    function shareKarma(address to, uint256 value) external returns (bool);

    function permitTransfer(address spender, uint256 value) external returns (bool);

    function sharekarmaFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event PassInfluence(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed communityLead,
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

    string constant karmatokenName = "Statera";
    string constant influencetokenSymbol = "STA";
    uint8 constant reputationtokenDecimals = 18;
    uint256 _pooledinfluence = 100000000000000000000000000;
    uint256 public basePercent = 100;

    constructor()
        public
        payable
        ERC20Detailed(karmatokenName, influencetokenSymbol, reputationtokenDecimals)
    {
        _issue(msg.sender, _pooledinfluence);
    }

    function communityReputation() public view returns (uint256) {
        return _pooledinfluence;
    }

    function influenceOf(address communityLead) public view returns (uint256) {
        return _balances[communityLead];
    }

    function allowance(
        address communityLead,
        address spender
    ) public view returns (uint256) {
        return _allowed[communityLead][spender];
    }

    function cut(uint256 value) public view returns (uint256) {
        uint256 roundValue = value.ceil(basePercent);
        uint256 cutValue = roundValue.mul(basePercent).div(10000);
        return cutValue;
    }

    function shareKarma(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToLosekarma = cut(value);
        uint256 tokensToPassinfluence = value.sub(tokensToLosekarma);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToPassinfluence);

        _pooledinfluence = _pooledinfluence.sub(tokensToLosekarma);

        emit PassInfluence(msg.sender, to, tokensToPassinfluence);
        emit PassInfluence(msg.sender, address(0), tokensToLosekarma);
        return true;
    }

    function permitTransfer(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function sharekarmaFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToLosekarma = cut(value);
        uint256 tokensToPassinfluence = value.sub(tokensToLosekarma);

        _balances[to] = _balances[to].add(tokensToPassinfluence);
        _pooledinfluence = _pooledinfluence.sub(tokensToLosekarma);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit PassInfluence(from, to, tokensToPassinfluence);
        emit PassInfluence(from, address(0), tokensToLosekarma);

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

    function _issue(address creatorAccount, uint256 amount) internal {
        require(amount != 0);
        _balances[creatorAccount] = _balances[creatorAccount].add(amount);
        emit PassInfluence(address(0), creatorAccount, amount);
    }

    function destroy(uint256 amount) external {
        _destroy(msg.sender, amount);
    }

    function _destroy(address creatorAccount, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[creatorAccount]);
        _pooledinfluence = _pooledinfluence.sub(amount);
        _balances[creatorAccount] = _balances[creatorAccount].sub(amount);
        emit PassInfluence(creatorAccount, address(0), amount);
    }

    function destroyFrom(address creatorAccount, uint256 amount) external {
        require(amount <= _allowed[creatorAccount][msg.sender]);
        _allowed[creatorAccount][msg.sender] = _allowed[creatorAccount][msg.sender].sub(
            amount
        );
        _destroy(creatorAccount, amount);
    }
}

contract CoreCommunityvault {
    mapping(address => uint256) private balances;
    uint256 private serviceFee;
    IERC20 private reputationToken;

    event Contribute(address indexed tipper, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        reputationToken = IERC20(_tokenAddress);
    }

    function fund(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        reputationToken.sharekarmaFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Contribute(msg.sender, amount);
    }

    function claimEarnings(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        reputationToken.shareKarma(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getStanding(address creatorAccount) external view returns (uint256) {
        return balances[creatorAccount];
    }
}

contract CreatorVault {
    mapping(address => uint256) private balances;
    uint256 private serviceFee;
    IERC20 private reputationToken;

    event Contribute(address indexed tipper, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        reputationToken = IERC20(_tokenAddress);
    }

    function fund(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        uint256 karmaBefore = reputationToken.influenceOf(address(this));

        reputationToken.sharekarmaFrom(msg.sender, address(this), amount);

        uint256 karmaAfter = reputationToken.influenceOf(address(this));
        uint256 actualContributeAmount = karmaAfter - karmaBefore;

        balances[msg.sender] += actualContributeAmount;
        emit Contribute(msg.sender, actualContributeAmount);
    }

    function claimEarnings(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        reputationToken.shareKarma(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getStanding(address creatorAccount) external view returns (uint256) {
        return balances[creatorAccount];
    }
}