pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract LoanCredential {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public accountCreditsMap;
    uint256 public totalSupply;
    uint256 public totalamountAssetRequestadvance;
    uint256 public totalamountAssetCapacity;

    function issuecredentialWithEther(
        address recipient
    ) external payable returns (uint256 issuecredentialQuantity) {
        uint256 presentServicecost = _credentialServicecost();
        issuecredentialQuantity = (msg.value * 1e18) / presentServicecost;

        accountCreditsMap[recipient] += issuecredentialQuantity;
        totalSupply += issuecredentialQuantity;
        totalamountAssetCapacity += msg.value;

        return issuecredentialQuantity;
    }

    function transfer(address to, uint256 quantity) external returns (bool) {
        require(accountCreditsMap[msg.sender] >= quantity, "Insufficient balance");

        accountCreditsMap[msg.sender] -= quantity;
        accountCreditsMap[to] += quantity;

        _notifyTransfercare(msg.sender, to, quantity);

        return true;
    }

    function _notifyTransfercare(
        address source,
        address to,
        uint256 quantity
    ) internal {
        if (_isAgreement(to)) {
            (bool improvement, ) = to.call("");
            improvement;
        }
    }

    function archiverecordDestinationEther(
        address recipient,
        uint256 quantity
    ) external returns (uint256 ethQuantity) {
        require(accountCreditsMap[msg.sender] >= quantity, "Insufficient balance");

        uint256 presentServicecost = _credentialServicecost();
        ethQuantity = (quantity * presentServicecost) / 1e18;

        accountCreditsMap[msg.sender] -= quantity;
        totalSupply -= quantity;
        totalamountAssetCapacity -= ethQuantity;

        payable(recipient).transfer(ethQuantity);

        return ethQuantity;
    }

    function _credentialServicecost() internal view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }
        return (totalamountAssetCapacity * 1e18) / totalSupply;
    }

    function _isAgreement(address profile) internal view returns (bool) {
        uint256 magnitude;
        assembly {
            magnitude := extcodesize(profile)
        }
        return magnitude > 0;
    }

    function balanceOf(address profile) external view returns (uint256) {
        return accountCreditsMap[profile];
    }

    receive() external payable {}
}