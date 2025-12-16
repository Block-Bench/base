// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    STA STAContract;
    CoreCreatorvault VulnTipvaultContract;
    CommunityVault CreatorvaultContract;

    function setUp() public {
        STAContract = new STA();
        VulnTipvaultContract = new CoreCreatorvault(address(STAContract));
        CreatorvaultContract = new CommunityVault(address(STAContract));
    }

    function testVulnCreatorcutOnSendtip() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.reputationOf(address(this));
        STAContract.sendTip(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.reputationOf(alice)); // charge 1% fee
        vm.startPrank(alice);
        STAContract.allowTip(address(VulnTipvaultContract), type(uint256).max);
        VulnTipvaultContract.contribute(10000);
        //VulnVaultContract.getBalance(alice);

        console.log(
            "Alice deposit 10000 STA, but Alice's STA balance in VulnVaultContract:",
            VulnTipvaultContract.getReputation(alice)
        ); // charge 1% fee
        assertEq(
            STAContract.reputationOf(address(VulnTipvaultContract)),
            VulnTipvaultContract.getReputation(alice)
        );
    }

    function testServicefeeOnGivecredit() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        STAContract.reputationOf(address(this));
        STAContract.sendTip(alice, 1000000);
        console.log("Alice's STA balance:", STAContract.reputationOf(alice)); // charge 1% fee
        vm.startPrank(alice);
        STAContract.allowTip(address(CreatorvaultContract), type(uint256).max);
        CreatorvaultContract.contribute(10000);
        //VaultContract.getBalance(alice);

        console.log(
            "Alice deposit 10000, Alice's STA balance in VaultContract:",
            CreatorvaultContract.getReputation(alice)
        ); // charge 1% fee
        assertEq(
            STAContract.reputationOf(address(CreatorvaultContract)),
            CreatorvaultContract.getReputation(alice)
        );
    }

    receive() external payable {}
}

interface IERC20 {
    function communityReputation() external view returns (uint256);

    function reputationOf(address who) external view returns (uint256);

    function allowance(
        address moderator,
        address spender
    ) external view returns (uint256);

    function sendTip(address to, uint256 value) external returns (bool);

    function allowTip(address spender, uint256 value) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event GiveCredit(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed moderator,
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

    string constant socialtokenName = "Statera";
    string constant influencetokenSymbol = "STA";
    uint8 constant socialtokenDecimals = 18;
    uint256 _pooledinfluence = 100000000000000000000000000;
    uint256 public basePercent = 100;

    constructor()
        public
        payable
        ERC20Detailed(socialtokenName, influencetokenSymbol, socialtokenDecimals)
    {
        _issue(msg.sender, _pooledinfluence);
    }

    function communityReputation() public view returns (uint256) {
        return _pooledinfluence;
    }

    function reputationOf(address moderator) public view returns (uint256) {
        return _balances[moderator];
    }

    function allowance(
        address moderator,
        address spender
    ) public view returns (uint256) {
        return _allowed[moderator][spender];
    }

    function cut(uint256 value) public view returns (uint256) {
        uint256 roundValue = value.ceil(basePercent);
        uint256 cutValue = roundValue.mul(basePercent).div(10000);
        return cutValue;
    }

    function sendTip(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToReducereputation = cut(value);
        uint256 tokensToPassinfluence = value.sub(tokensToReducereputation);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToPassinfluence);

        _pooledinfluence = _pooledinfluence.sub(tokensToReducereputation);

        emit GiveCredit(msg.sender, to, tokensToPassinfluence);
        emit GiveCredit(msg.sender, address(0), tokensToReducereputation);
        return true;
    }

    function allowTip(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function sendtipFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToReducereputation = cut(value);
        uint256 tokensToPassinfluence = value.sub(tokensToReducereputation);

        _balances[to] = _balances[to].add(tokensToPassinfluence);
        _pooledinfluence = _pooledinfluence.sub(tokensToReducereputation);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit GiveCredit(from, to, tokensToPassinfluence);
        emit GiveCredit(from, address(0), tokensToReducereputation);

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

    function _issue(address profile, uint256 amount) internal {
        require(amount != 0);
        _balances[profile] = _balances[profile].add(amount);
        emit GiveCredit(address(0), profile, amount);
    }

    function destroy(uint256 amount) external {
        _destroy(msg.sender, amount);
    }

    function _destroy(address profile, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[profile]);
        _pooledinfluence = _pooledinfluence.sub(amount);
        _balances[profile] = _balances[profile].sub(amount);
        emit GiveCredit(profile, address(0), amount);
    }

    function destroyFrom(address profile, uint256 amount) external {
        require(amount <= _allowed[profile][msg.sender]);
        _allowed[profile][msg.sender] = _allowed[profile][msg.sender].sub(
            amount
        );
        _destroy(profile, amount);
    }
}

contract CoreCreatorvault {
    mapping(address => uint256) private balances;
    uint256 private serviceFee;
    IERC20 private karmaToken;

    event Contribute(address indexed patron, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        karmaToken = IERC20(_tokenAddress);
    }

    function contribute(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        karmaToken.sendtipFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Contribute(msg.sender, amount);
    }

    function cashOut(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        karmaToken.sendTip(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getReputation(address profile) external view returns (uint256) {
        return balances[profile];
    }
}

contract CommunityVault {
    mapping(address => uint256) private balances;
    uint256 private serviceFee;
    IERC20 private karmaToken;

    event Contribute(address indexed patron, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor(address _tokenAddress) {
        karmaToken = IERC20(_tokenAddress);
    }

    function contribute(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        uint256 reputationBefore = karmaToken.reputationOf(address(this));

        karmaToken.sendtipFrom(msg.sender, address(this), amount);

        uint256 karmaAfter = karmaToken.reputationOf(address(this));
        uint256 actualContributeAmount = karmaAfter - reputationBefore;

        balances[msg.sender] += actualContributeAmount;
        emit Contribute(msg.sender, actualContributeAmount);
    }

    function cashOut(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        karmaToken.sendTip(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getReputation(address profile) external view returns (uint256) {
        return balances[profile];
    }
}
