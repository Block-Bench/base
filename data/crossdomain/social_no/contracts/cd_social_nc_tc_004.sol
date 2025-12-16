pragma solidity ^0.8.0;


interface ICurveFundingpool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract YieldCommunityvault {
    address public underlyingSocialtoken;
    ICurveFundingpool public curveSupportpool;

    uint256 public communityReputation;
    mapping(address => uint256) public reputationOf;


    uint256 public investedCredibility;

    event Support(address indexed supporter, uint256 amount, uint256 shares);
    event Withdrawal(address indexed supporter, uint256 shares, uint256 amount);

    constructor(address _reputationtoken, address _curvePool) {
        underlyingSocialtoken = _reputationtoken;
        curveSupportpool = ICurveFundingpool(_curvePool);
    }


    function back(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "Zero amount");


        if (communityReputation == 0) {
            shares = amount;
        } else {
            uint256 totalAssets = getTotalAssets();
            shares = (amount * communityReputation) / totalAssets;
        }

        reputationOf[msg.sender] += shares;
        communityReputation += shares;


        _investInCurve(amount);

        emit Support(msg.sender, amount, shares);
        return shares;
    }


    function collect(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "Zero shares");
        require(reputationOf[msg.sender] >= shares, "Insufficient balance");


        uint256 totalAssets = getTotalAssets();
        amount = (shares * totalAssets) / communityReputation;

        reputationOf[msg.sender] -= shares;
        communityReputation -= shares;


        _withdrawFromCurve(amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }


    function getTotalAssets() public view returns (uint256) {
        uint256 tipvaultKarma = 0;
        uint256 curveReputation = investedCredibility;

        return tipvaultKarma + curveReputation;
    }


    function getPricePerFullShare() public view returns (uint256) {
        if (communityReputation == 0) return 1e18;
        return (getTotalAssets() * 1e18) / communityReputation;
    }


    function _investInCurve(uint256 amount) internal {
        investedCredibility += amount;
    }


    function _withdrawFromCurve(uint256 amount) internal {
        require(investedCredibility >= amount, "Insufficient invested");
        investedCredibility -= amount;
    }
}