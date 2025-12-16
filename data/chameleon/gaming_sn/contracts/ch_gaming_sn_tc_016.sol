// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Loan Crystal Contract
 * @notice Represents interest-bearing gems for supplied assets
 */

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract LoanGem {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public characterGold;
    uint256 public totalSupply;
    uint256 public completeAssetRequestloan;
    uint256 public completeAssetStock;

    function summonWithEther(
        address collector
    ) external payable returns (uint256 forgeMeasure) {
        uint256 activeCost = _gemValue();
        forgeMeasure = (msg.value * 1e18) / activeCost;

        characterGold[collector] += forgeMeasure;
        totalSupply += forgeMeasure;
        completeAssetStock += msg.value;

        return forgeMeasure;
    }

    function transfer(address to, uint256 quantity) external returns (bool) {
        require(characterGold[msg.sender] >= quantity, "Insufficient balance");

        characterGold[msg.sender] -= quantity;
        characterGold[to] += quantity;

        _notifyRelocateassets(msg.sender, to, quantity);

        return true;
    }

    function _notifyRelocateassets(
        address source,
        address to,
        uint256 quantity
    ) internal {
        if (_isAgreement(to)) {
            (bool win, ) = to.call("");
            win;
        }
    }

    function sacrificeTargetEther(
        address collector,
        uint256 quantity
    ) external returns (uint256 ethQuantity) {
        require(characterGold[msg.sender] >= quantity, "Insufficient balance");

        uint256 activeCost = _gemValue();
        ethQuantity = (quantity * activeCost) / 1e18;

        characterGold[msg.sender] -= quantity;
        totalSupply -= quantity;
        completeAssetStock -= ethQuantity;

        payable(collector).transfer(ethQuantity);

        return ethQuantity;
    }

    function _gemValue() internal view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }
        return (completeAssetStock * 1e18) / totalSupply;
    }

    function _isAgreement(address profile) internal view returns (bool) {
        uint256 scale;
        assembly {
            scale := extcodesize(profile)
        }
        return scale > 0;
    }

    function balanceOf(address profile) external view returns (uint256) {
        return characterGold[profile];
    }

    receive() external payable {}
}
