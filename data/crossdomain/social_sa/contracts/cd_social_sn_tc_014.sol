// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Supportpool {
    function add_liquidreputation(
        uint256[3] memory amounts,
        uint256 min_buildinfluence_amount
    ) external;

    function remove_liquidreputation_imbalance(
        uint256[3] memory amounts,
        uint256 max_spendinfluence_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function giveCredit(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function influenceOf(address profile) external view returns (uint256);

    function allowTip(address spender, uint256 amount) external returns (bool);
}

contract YieldTipvault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Supportpool public curve3Fundingpool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Fundingpool = ICurve3Supportpool(_curve3Pool);
    }

    function donate(uint256 amount) external {
        dai.sendtipFrom(msg.sender, address(this), amount);

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
        uint256 communityvaultKarma = dai.influenceOf(address(this));
        require(
            communityvaultKarma >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Fundingpool.get_virtual_price();

        dai.allowTip(address(curve3Fundingpool), communityvaultKarma);
        uint256[3] memory amounts = [communityvaultKarma, 0, 0];
        curve3Fundingpool.add_liquidreputation(amounts, 0);
    }

    function redeemkarmaAll() external {
        uint256 memberShares = shares[msg.sender];
        require(memberShares > 0, "No shares");

        uint256 redeemkarmaAmount = (memberShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= memberShares;
        totalDeposits -= redeemkarmaAmount;

        dai.giveCredit(msg.sender, redeemkarmaAmount);
    }

    function influence() public view returns (uint256) {
        return
            dai.influenceOf(address(this)) +
            (crv3.influenceOf(address(this)) * curve3Fundingpool.get_virtual_price()) /
            1e18;
    }
}
