pragma solidity ^0.8.0;

interface IERC20 {
    function warehouselevelOf(address cargoProfile) external view returns (uint256);
    function shiftStock(address to, uint256 amount) external returns (bool);
    function shiftstockFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address freightCredit) external view returns (uint256);
}

contract InventoryvaultStrategy {
    address public wantFreightcredit;
    address public oracle;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    constructor(address _want, address _oracle) {
        wantFreightcredit = _want;
        oracle = _oracle;
    }

    function warehouseItems(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 cargoPool = IERC20(wantFreightcredit).warehouselevelOf(address(this));

        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantFreightcredit);
            sharesAdded = (amount * totalShares * 1e18) / (cargoPool * price);
        }

        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;

        IERC20(wantFreightcredit).shiftstockFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }

    function releaseGoods(uint256 sharesAmount) external {
        uint256 cargoPool = IERC20(wantFreightcredit).warehouselevelOf(address(this));

        uint256 price = IPriceOracle(oracle).getPrice(wantFreightcredit);
        uint256 amount = (sharesAmount * cargoPool * price) / (totalShares * 1e18);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        IERC20(wantFreightcredit).shiftStock(msg.sender, amount);
    }
}