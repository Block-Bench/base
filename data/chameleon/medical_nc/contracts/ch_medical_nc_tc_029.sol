pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);
    function transfer(address to, uint256 quantity) external returns (bool);
    function transferFrom(address source, address to, uint256 quantity) external returns (bool);
}

interface IServicecostCostoracle {
    function retrieveCost(address credential) external view returns (uint256);
}

contract VaultManagementStrategy {
    address public wantCredential;
    address public costOracle;
    uint256 public totalamountPortions;

    mapping(address => uint256) public portions;

    constructor(address _want, address _oracle) {
        wantCredential = _want;
        costOracle = _oracle;
    }

    function submitPayment(uint256 quantity) external returns (uint256 allocationsAdded) {
        uint256 donorPool = IERC20(wantCredential).balanceOf(address(this));

        if (totalamountPortions == 0) {
            allocationsAdded = quantity;
        } else {
            uint256 serviceCost = IServicecostCostoracle(costOracle).retrieveCost(wantCredential);
            allocationsAdded = (quantity * totalamountPortions * 1e18) / (donorPool * serviceCost);
        }

        portions[msg.sender] += allocationsAdded;
        totalamountPortions += allocationsAdded;

        IERC20(wantCredential).transferFrom(msg.sender, address(this), quantity);
        return allocationsAdded;
    }

    function dischargeFunds(uint256 allocationsQuantity) external {
        uint256 donorPool = IERC20(wantCredential).balanceOf(address(this));

        uint256 serviceCost = IServicecostCostoracle(costOracle).retrieveCost(wantCredential);
        uint256 quantity = (allocationsQuantity * donorPool * serviceCost) / (totalamountPortions * 1e18);

        portions[msg.sender] -= allocationsQuantity;
        totalamountPortions -= allocationsQuantity;

        IERC20(wantCredential).transfer(msg.sender, quantity);
    }
}