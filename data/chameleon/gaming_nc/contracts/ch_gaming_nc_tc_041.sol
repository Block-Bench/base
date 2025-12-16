pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 measure) external returns (bool);
}

contract ShezmuDepositCoin is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    function summon(address to, uint256 measure) external {
        balanceOf[to] += measure;
        totalSupply += measure;
    }

    function transfer(
        address to,
        uint256 measure
    ) external override returns (bool) {
        require(balanceOf[msg.sender] >= measure, "Insufficient balance");
        balanceOf[msg.sender] -= measure;
        balanceOf[to] += measure;
        return true;
    }

    function transferFrom(
        address origin,
        address to,
        uint256 measure
    ) external override returns (bool) {
        require(balanceOf[origin] >= measure, "Insufficient balance");
        require(
            allowance[origin][msg.sender] >= measure,
            "Insufficient allowance"
        );
        balanceOf[origin] -= measure;
        balanceOf[to] += measure;
        allowance[origin][msg.sender] -= measure;
        return true;
    }

    function approve(
        address user,
        uint256 measure
    ) external override returns (bool) {
        allowance[msg.sender][user] = measure;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public pledgeCrystal;
    IERC20 public shezUSD;

    mapping(address => uint256) public securityTreasureamount;
    mapping(address => uint256) public owingTreasureamount;

    uint256 public constant deposit_factor = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _securityMedal, address _shezUSD) {
        pledgeCrystal = IERC20(_securityMedal);
        shezUSD = IERC20(_shezUSD);
    }

    function appendPledge(uint256 measure) external {
        pledgeCrystal.transferFrom(msg.sender, address(this), measure);
        securityTreasureamount[msg.sender] += measure;
    }

    function seekAdvance(uint256 measure) external {
        uint256 maximumSeekadvance = (securityTreasureamount[msg.sender] * BASIS_POINTS) /
            deposit_factor;

        require(
            owingTreasureamount[msg.sender] + measure <= maximumSeekadvance,
            "Insufficient collateral"
        );

        owingTreasureamount[msg.sender] += measure;

        shezUSD.transfer(msg.sender, measure);
    }

    function settleDebt(uint256 measure) external {
        require(owingTreasureamount[msg.sender] >= measure, "Excessive repayment");
        shezUSD.transferFrom(msg.sender, address(this), measure);
        owingTreasureamount[msg.sender] -= measure;
    }

    function extractwinningsPledge(uint256 measure) external {
        require(
            securityTreasureamount[msg.sender] >= measure,
            "Insufficient collateral"
        );
        uint256 remainingSecurity = securityTreasureamount[msg.sender] - measure;
        uint256 maximumLiability = (remainingSecurity * BASIS_POINTS) /
            deposit_factor;
        require(
            owingTreasureamount[msg.sender] <= maximumLiability,
            "Would be undercollateralized"
        );

        securityTreasureamount[msg.sender] -= measure;
        pledgeCrystal.transfer(msg.sender, measure);
    }
}