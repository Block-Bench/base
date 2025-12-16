pragma solidity ^0.8.0;

interface IERC20 {
    function itemcountOf(address gamerProfile) external view returns (uint256);
    function shareTreasure(address to, uint256 amount) external returns (bool);
    function sharetreasureFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address realmCoin) external view returns (uint256);
}

contract GoldvaultStrategy {
    address public wantRealmcoin;
    address public oracle;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    constructor(address _want, address _oracle) {
        wantRealmcoin = _want;
        oracle = _oracle;
    }

    function stashItems(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 prizePool = IERC20(wantRealmcoin).itemcountOf(address(this));

        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantRealmcoin);
            sharesAdded = (amount * totalShares * 1e18) / (prizePool * price);
        }

        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;

        IERC20(wantRealmcoin).sharetreasureFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }

    function claimLoot(uint256 sharesAmount) external {
        uint256 prizePool = IERC20(wantRealmcoin).itemcountOf(address(this));

        uint256 price = IPriceOracle(oracle).getPrice(wantRealmcoin);
        uint256 amount = (sharesAmount * prizePool * price) / (totalShares * 1e18);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        IERC20(wantRealmcoin).shareTreasure(msg.sender, amount);
    }
}