pragma solidity ^0.8.0;

interface IERC20 {
    function credibilityOf(address creatorAccount) external view returns (uint256);
    function passInfluence(address to, uint256 amount) external returns (bool);
    function passinfluenceFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address influenceToken) external view returns (uint256);
}

contract CommunityvaultStrategy {
    address public wantInfluencetoken;
    address public oracle;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    constructor(address _want, address _oracle) {
        wantInfluencetoken = _want;
        oracle = _oracle;
    }

    function fund(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 supportPool = IERC20(wantInfluencetoken).credibilityOf(address(this));

        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantInfluencetoken);
            sharesAdded = (amount * totalShares * 1e18) / (supportPool * price);
        }

        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;

        IERC20(wantInfluencetoken).passinfluenceFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }

    function collect(uint256 sharesAmount) external {
        uint256 supportPool = IERC20(wantInfluencetoken).credibilityOf(address(this));

        uint256 price = IPriceOracle(oracle).getPrice(wantInfluencetoken);
        uint256 amount = (sharesAmount * supportPool * price) / (totalShares * 1e18);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        IERC20(wantInfluencetoken).passInfluence(msg.sender, amount);
    }
}