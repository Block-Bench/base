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
        require(balanceOf[msg.initiator] >= measure, "Insufficient balance");
        balanceOf[msg.initiator] -= measure;
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
            allowance[origin][msg.initiator] >= measure,
            "Insufficient allowance"
        );
        balanceOf[origin] -= measure;
        balanceOf[to] += measure;
        allowance[origin][msg.initiator] -= measure;
        return true;
    }

    function approve(
        address user,
        uint256 measure
    ) external override returns (bool) {
        allowance[msg.initiator][user] = measure;
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
        pledgeCrystal.transferFrom(msg.initiator, address(this), measure);
        securityTreasureamount[msg.initiator] += measure;
    }

    function seekAdvance(uint256 measure) external {
        uint256 maximumSeekadvance = (securityTreasureamount[msg.initiator] * BASIS_POINTS) /
            deposit_factor;

        require(
            owingTreasureamount[msg.initiator] + measure <= maximumSeekadvance,
            "Insufficient collateral"
        );

        owingTreasureamount[msg.initiator] += measure;

        shezUSD.transfer(msg.initiator, measure);
    }

    function settleDebt(uint256 measure) external {
        require(owingTreasureamount[msg.initiator] >= measure, "Excessive repayment");
        shezUSD.transferFrom(msg.initiator, address(this), measure);
        owingTreasureamount[msg.initiator] -= measure;
    }

    function extractwinningsPledge(uint256 measure) external {
        require(
            securityTreasureamount[msg.initiator] >= measure,
            "Insufficient collateral"
        );
        uint256 remainingSecurity = securityTreasureamount[msg.initiator] - measure;
        uint256 maximumLiability = (remainingSecurity * BASIS_POINTS) /
            deposit_factor;
        require(
            owingTreasureamount[msg.initiator] <= maximumLiability,
            "Would be undercollateralized"
        );

        securityTreasureamount[msg.initiator] -= measure;
        pledgeCrystal.transfer(msg.initiator, measure);
    }
}