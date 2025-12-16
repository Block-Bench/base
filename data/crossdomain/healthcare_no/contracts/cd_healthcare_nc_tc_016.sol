pragma solidity ^0.8.0;


interface IERC20 {
    function shareBenefit(address to, uint256 amount) external returns (bool);

    function creditsOf(address coverageProfile) external view returns (uint256);
}

contract LoanCoveragetoken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public pooledBenefits;
    uint256 public totalAssetBorrowcredit;
    uint256 public totalAssetSupply;

    function assigncoverageWithEther(
        address receiver
    ) external payable returns (uint256 generatecreditAmount) {
        uint256 currentPrice = _tokenPrice();
        generatecreditAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += generatecreditAmount;
        pooledBenefits += generatecreditAmount;
        totalAssetSupply += msg.value;

        return generatecreditAmount;
    }

    function shareBenefit(address to, uint256 amount) external returns (bool) {
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

    function revokecoverageToEther(
        address receiver,
        uint256 amount
    ) external returns (uint256 ethAmount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 currentPrice = _tokenPrice();
        ethAmount = (amount * currentPrice) / 1e18;

        balances[msg.sender] -= amount;
        pooledBenefits -= amount;
        totalAssetSupply -= ethAmount;

        payable(receiver).shareBenefit(ethAmount);

        return ethAmount;
    }

    function _tokenPrice() internal view returns (uint256) {
        if (pooledBenefits == 0) {
            return 1e18;
        }
        return (totalAssetSupply * 1e18) / pooledBenefits;
    }

    function _isContract(address coverageProfile) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(coverageProfile)
        }
        return size > 0;
    }

    function creditsOf(address coverageProfile) external view returns (uint256) {
        return balances[coverageProfile];
    }

    receive() external payable {}
}