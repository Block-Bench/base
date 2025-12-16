pragma solidity ^0.8.0;


interface ICurve3Donationpool {
    function add_spendableinfluence(
        uint256[3] memory amounts,
        uint256 min_buildinfluence_amount
    ) external;

    function remove_spendableinfluence_imbalance(
        uint256[3] memory amounts,
        uint256 max_reducereputation_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function sharekarmaFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function influenceOf(address creatorAccount) external view returns (uint256);

    function permitTransfer(address spender, uint256 amount) external returns (bool);
}

contract YieldCreatorvault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Donationpool public curve3Supportpool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Supportpool = ICurve3Donationpool(_curve3Pool);
    }

    function support(uint256 amount) external {
        dai.sharekarmaFrom(msg.sender, address(this), amount);

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
        uint256 patronvaultStanding = dai.influenceOf(address(this));
        require(
            patronvaultStanding >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Supportpool.get_virtual_price();

        dai.permitTransfer(address(curve3Supportpool), patronvaultStanding);
        uint256[3] memory amounts = [patronvaultStanding, 0, 0];
        curve3Supportpool.add_spendableinfluence(amounts, 0);
    }

    function collectAll() external {
        uint256 followerShares = shares[msg.sender];
        require(followerShares > 0, "No shares");

        uint256 redeemkarmaAmount = (followerShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= followerShares;
        totalDeposits -= redeemkarmaAmount;

        dai.sendTip(msg.sender, redeemkarmaAmount);
    }

    function standing() public view returns (uint256) {
        return
            dai.influenceOf(address(this)) +
            (crv3.influenceOf(address(this)) * curve3Supportpool.get_virtual_price()) /
            1e18;
    }
}