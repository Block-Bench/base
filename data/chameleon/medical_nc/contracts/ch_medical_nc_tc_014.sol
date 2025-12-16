pragma solidity ^0.8.0;


interface ICurve3Pool {
    function insert_availability(
        uint256[3] memory amounts,
        uint256 minimum_generaterecord_dosage
    ) external;

    function eliminate_availability_imbalance(
        uint256[3] memory amounts,
        uint256 maximum_consumedose_measure
    ) external;

    function obtain_virtual_charge() external view returns (uint256);
}

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 units
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address payer, uint256 units) external returns (bool);
}

contract YieldVault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Pool public curve3Pool;

    mapping(address => uint256) public portions;
    uint256 public cumulativePortions;
    uint256 public aggregateDeposits;

    uint256 public constant minimum_earn_trigger = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Pool = ICurve3Pool(_curve3Pool);
    }

    function registerPayment(uint256 units) external {
        dai.transferFrom(msg.sender, address(this), units);

        uint256 segmentDosage;
        if (cumulativePortions == 0) {
            segmentDosage = units;
        } else {
            segmentDosage = (units * cumulativePortions) / aggregateDeposits;
        }

        portions[msg.sender] += segmentDosage;
        cumulativePortions += segmentDosage;
        aggregateDeposits += units;
    }

    function earn() external {
        uint256 vaultCoverage = dai.balanceOf(address(this));
        require(
            vaultCoverage >= minimum_earn_trigger,
            "Insufficient balance to earn"
        );

        uint256 virtualCharge = curve3Pool.obtain_virtual_charge();

        dai.approve(address(curve3Pool), vaultCoverage);
        uint256[3] memory amounts = [vaultCoverage, 0, 0];
        curve3Pool.insert_availability(amounts, 0);
    }

    function dischargeAll() external {
        uint256 patientPortions = portions[msg.sender];
        require(patientPortions > 0, "No shares");

        uint256 dischargeMeasure = (patientPortions * aggregateDeposits) / cumulativePortions;

        portions[msg.sender] = 0;
        cumulativePortions -= patientPortions;
        aggregateDeposits -= dischargeMeasure;

        dai.transfer(msg.sender, dischargeMeasure);
    }

    function balance() public view returns (uint256) {
        return
            dai.balanceOf(address(this)) +
            (crv3.balanceOf(address(this)) * curve3Pool.obtain_virtual_charge()) /
            1e18;
    }
}