pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function karmaOf(address socialProfile) external view returns (uint256);

    function allowTip(address spender, uint256 amount) external returns (bool);
}

contract ShezmuGuaranteeKarmatoken is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public karmaOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public pooledInfluence;

    function gainReputation(address to, uint256 amount) external {
        karmaOf[to] += amount;
        pooledInfluence += amount;
    }

    function passInfluence(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(karmaOf[msg.sender] >= amount, "Insufficient balance");
        karmaOf[msg.sender] -= amount;
        karmaOf[to] += amount;
        return true;
    }

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(karmaOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        karmaOf[from] -= amount;
        karmaOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function allowTip(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ShezmuCommunityvault {
    IERC20 public commitmentInfluencetoken;
    IERC20 public shezUSD;

    mapping(address => uint256) public bondStanding;
    mapping(address => uint256) public reputationdebtCredibility;

    uint256 public constant pledge_ratio = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        commitmentInfluencetoken = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addPledge(uint256 amount) external {
        commitmentInfluencetoken.sendtipFrom(msg.sender, address(this), amount);
        bondStanding[msg.sender] += amount;
    }

    function seekFunding(uint256 amount) external {
        uint256 maxAskforbacking = (bondStanding[msg.sender] * BASIS_POINTS) /
            pledge_ratio;

        require(
            reputationdebtCredibility[msg.sender] + amount <= maxAskforbacking,
            "Insufficient collateral"
        );

        reputationdebtCredibility[msg.sender] += amount;

        shezUSD.passInfluence(msg.sender, amount);
    }

    function fulfillPledge(uint256 amount) external {
        require(reputationdebtCredibility[msg.sender] >= amount, "Excessive repayment");
        shezUSD.sendtipFrom(msg.sender, address(this), amount);
        reputationdebtCredibility[msg.sender] -= amount;
    }

    function collectBond(uint256 amount) external {
        require(
            bondStanding[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingGuarantee = bondStanding[msg.sender] - amount;
        uint256 maxPendingobligation = (remainingGuarantee * BASIS_POINTS) /
            pledge_ratio;
        require(
            reputationdebtCredibility[msg.sender] <= maxPendingobligation,
            "Would be undercollateralized"
        );

        bondStanding[msg.sender] -= amount;
        commitmentInfluencetoken.passInfluence(msg.sender, amount);
    }
}