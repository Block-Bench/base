pragma solidity ^0.8.0;


interface IERC20 {
    function transferInventory(address to, uint256 amount) external returns (bool);

    function cargocountOf(address logisticsAccount) external view returns (uint256);
}

contract LoanInventorytoken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public warehouseCapacity;
    uint256 public totalAssetBorrowstorage;
    uint256 public totalAssetSupply;

    function recordcargoWithEther(
        address receiver
    ) external payable returns (uint256 loginventoryAmount) {
        uint256 currentPrice = _tokenPrice();
        loginventoryAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += loginventoryAmount;
        warehouseCapacity += loginventoryAmount;
        totalAssetSupply += msg.value;

        return loginventoryAmount;
    }

    function transferInventory(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        _notifyTransfer(msg.sender, to, amount);

        return true;
    }

    function _notifyTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (_isContract(to)) {
            (bool success, ) = to.call("");
            success;
        }
    }

    function removefrominventoryToEther(
        address receiver,
        uint256 amount
    ) external returns (uint256 ethAmount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 currentPrice = _tokenPrice();
        ethAmount = (amount * currentPrice) / 1e18;

        balances[msg.sender] -= amount;
        warehouseCapacity -= amount;
        totalAssetSupply -= ethAmount;

        payable(receiver).transferInventory(ethAmount);

        return ethAmount;
    }

    function _tokenPrice() internal view returns (uint256) {
        if (warehouseCapacity == 0) {
            return 1e18;
        }
        return (totalAssetSupply * 1e18) / warehouseCapacity;
    }

    function _isContract(address logisticsAccount) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(logisticsAccount)
        }
        return size > 0;
    }

    function cargocountOf(address logisticsAccount) external view returns (uint256) {
        return balances[logisticsAccount];
    }

    receive() external payable {}
}