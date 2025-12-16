pragma solidity ^0.8.0;


interface ICurve3Claimpool {
    function add_accessiblecoverage(
        uint256[3] memory amounts,
        uint256 min_generatecredit_amount
    ) external;

    function remove_accessiblecoverage_imbalance(
        uint256[3] memory amounts,
        uint256 max_removecoverage_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function creditsOf(address memberRecord) external view returns (uint256);

    function validateClaim(address spender, uint256 amount) external returns (bool);
}

contract YieldBenefitvault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Claimpool public curve3Benefitpool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Benefitpool = ICurve3Claimpool(_curve3Pool);
    }

    function payPremium(uint256 amount) external {
        dai.movecoverageFrom(msg.sender, address(this), amount);

        uint256 shareAmount;
        if (totalShares == 0) {
            shareAmount = amount;
        } else {
            shareAmount = (amount * totalShares) / totalDeposits;
        }

        shares[msg.sender] += shareAmount;
        totalShares += shareAmount;
        totalDeposits += amount;
    }

    function earn() external {
        uint256 healthvaultAllowance = dai.creditsOf(address(this));
        require(
            healthvaultAllowance >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Benefitpool.get_virtual_price();

        dai.validateClaim(address(curve3Benefitpool), healthvaultAllowance);
        uint256[3] memory amounts = [healthvaultAllowance, 0, 0];
        curve3Benefitpool.add_accessiblecoverage(amounts, 0);
    }

    function claimbenefitAll() external {
        uint256 participantShares = shares[msg.sender];
        require(participantShares > 0, "No shares");

        uint256 collectcoverageAmount = (participantShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= participantShares;
        totalDeposits -= collectcoverageAmount;

        dai.transferBenefit(msg.sender, collectcoverageAmount);
    }

    function allowance() public view returns (uint256) {
        return
            dai.creditsOf(address(this)) +
            (crv3.creditsOf(address(this)) * curve3Benefitpool.get_virtual_price()) /
            1e18;
    }
}