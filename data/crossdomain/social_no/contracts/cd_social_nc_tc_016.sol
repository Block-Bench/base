pragma solidity ^0.8.0;


interface IERC20 {
    function giveCredit(address to, uint256 amount) external returns (bool);

    function influenceOf(address socialProfile) external view returns (uint256);
}

contract LoanReputationtoken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public communityReputation;
    uint256 public totalAssetSeekfunding;
    uint256 public totalAssetSupply;

    function buildinfluenceWithEther(
        address receiver
    ) external payable returns (uint256 earnkarmaAmount) {
        uint256 currentPrice = _tokenPrice();
        earnkarmaAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += earnkarmaAmount;
        communityReputation += earnkarmaAmount;
        totalAssetSupply += msg.value;

        return earnkarmaAmount;
    }

    function giveCredit(address to, uint256 amount) external returns (bool) {
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

    function losekarmaToEther(
        address receiver,
        uint256 amount
    ) external returns (uint256 ethAmount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 currentPrice = _tokenPrice();
        ethAmount = (amount * currentPrice) / 1e18;

        balances[msg.sender] -= amount;
        communityReputation -= amount;
        totalAssetSupply -= ethAmount;

        payable(receiver).giveCredit(ethAmount);

        return ethAmount;
    }

    function _tokenPrice() internal view returns (uint256) {
        if (communityReputation == 0) {
            return 1e18;
        }
        return (totalAssetSupply * 1e18) / communityReputation;
    }

    function _isContract(address socialProfile) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(socialProfile)
        }
        return size > 0;
    }

    function influenceOf(address socialProfile) external view returns (uint256) {
        return balances[socialProfile];
    }

    receive() external payable {}
}