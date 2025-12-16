pragma solidity ^0.8.0;


interface ICurve3Bountypool {
    function add_freeitems(
        uint256[3] memory amounts,
        uint256 min_craftgear_amount
    ) external;

    function remove_freeitems_imbalance(
        uint256[3] memory amounts,
        uint256 max_useitem_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function treasurecountOf(address gamerProfile) external view returns (uint256);

    function allowTransfer(address spender, uint256 amount) external returns (bool);
}

contract YieldLootvault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Bountypool public curve3Prizepool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Prizepool = ICurve3Bountypool(_curve3Pool);
    }

    function savePrize(uint256 amount) external {
        dai.giveitemsFrom(msg.sender, address(this), amount);

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
        uint256 itemvaultGemtotal = dai.treasurecountOf(address(this));
        require(
            itemvaultGemtotal >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Prizepool.get_virtual_price();

        dai.allowTransfer(address(curve3Prizepool), itemvaultGemtotal);
        uint256[3] memory amounts = [itemvaultGemtotal, 0, 0];
        curve3Prizepool.add_freeitems(amounts, 0);
    }

    function claimlootAll() external {
        uint256 warriorShares = shares[msg.sender];
        require(warriorShares > 0, "No shares");

        uint256 redeemgoldAmount = (warriorShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= warriorShares;
        totalDeposits -= redeemgoldAmount;

        dai.sendGold(msg.sender, redeemgoldAmount);
    }

    function gemTotal() public view returns (uint256) {
        return
            dai.treasurecountOf(address(this)) +
            (crv3.treasurecountOf(address(this)) * curve3Prizepool.get_virtual_price()) /
            1e18;
    }
}