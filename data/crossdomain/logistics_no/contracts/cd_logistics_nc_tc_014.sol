pragma solidity ^0.8.0;


interface ICurve3Freightpool {
    function add_freecapacity(
        uint256[3] memory amounts,
        uint256 min_loginventory_amount
    ) external;

    function remove_freecapacity_imbalance(
        uint256[3] memory amounts,
        uint256 max_clearrecord_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function cargocountOf(address cargoProfile) external view returns (uint256);

    function approveDispatch(address spender, uint256 amount) external returns (bool);
}

contract YieldStoragevault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Freightpool public curve3Cargopool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Cargopool = ICurve3Freightpool(_curve3Pool);
    }

    function stockInventory(uint256 amount) external {
        dai.relocatecargoFrom(msg.sender, address(this), amount);

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
        uint256 cargovaultGoodsonhand = dai.cargocountOf(address(this));
        require(
            cargovaultGoodsonhand >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Cargopool.get_virtual_price();

        dai.approveDispatch(address(curve3Cargopool), cargovaultGoodsonhand);
        uint256[3] memory amounts = [cargovaultGoodsonhand, 0, 0];
        curve3Cargopool.add_freecapacity(amounts, 0);
    }

    function releasegoodsAll() external {
        uint256 buyerShares = shares[msg.sender];
        require(buyerShares > 0, "No shares");

        uint256 checkoutcargoAmount = (buyerShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= buyerShares;
        totalDeposits -= checkoutcargoAmount;

        dai.moveGoods(msg.sender, checkoutcargoAmount);
    }

    function goodsOnHand() public view returns (uint256) {
        return
            dai.cargocountOf(address(this)) +
            (crv3.cargocountOf(address(this)) * curve3Cargopool.get_virtual_price()) /
            1e18;
    }
}