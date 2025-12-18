pragma solidity ^0.8.0;


interface ICurve3Pool {
    function insert_availableresources(
        uint256[3] memory amounts,
        uint256 minimum_issuecredential_quantity
    ) external;

    function eliminate_availableresources_imbalance(
        uint256[3] memory amounts,
        uint256 maximum_archiverecord_quantity
    ) external;

    function obtain_virtual_servicecost() external view returns (uint256);
}

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

contract BenefitAccrualVault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Pool public curve3Pool;

    mapping(address => uint256) public portions;
    uint256 public totalamountPortions;
    uint256 public totalamountPayments;

    uint256 public constant minimum_accruebenefit_limit = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Pool = ICurve3Pool(_curve3Pool);
    }

    function submitPayment(uint256 quantity) external {
        dai.transferFrom(msg.sender, address(this), quantity);

        uint256 portionQuantity;
        if (totalamountPortions == 0) {
            portionQuantity = quantity;
        } else {
            portionQuantity = (quantity * totalamountPortions) / totalamountPayments;
        }

        portions[msg.sender] += portionQuantity;
        totalamountPortions += portionQuantity;
        totalamountPayments += quantity;
    }

    function accrueBenefit() external {
        uint256 vaultAccountcredits = dai.balanceOf(address(this));
        require(
            vaultAccountcredits >= minimum_accruebenefit_limit,
            "Insufficient balance to earn"
        );

        uint256 virtualServicecost = curve3Pool.obtain_virtual_servicecost();

        dai.approve(address(curve3Pool), vaultAccountcredits);
        uint256[3] memory amounts = [vaultAccountcredits, 0, 0];
        curve3Pool.insert_availableresources(amounts, 0);
    }

    function dischargeAllFunds() external {
        uint256 patientPortions = portions[msg.sender];
        require(patientPortions > 0, "No shares");

        uint256 dischargefundsQuantity = (patientPortions * totalamountPayments) / totalamountPortions;

        portions[msg.sender] = 0;
        totalamountPortions -= patientPortions;
        totalamountPayments -= dischargefundsQuantity;

        dai.transfer(msg.sender, dischargefundsQuantity);
    }

    function balance() public view returns (uint256) {
        return
            dai.balanceOf(address(this)) +
            (crv3.balanceOf(address(this)) * curve3Pool.obtain_virtual_servicecost()) /
            1e18;
    }
}