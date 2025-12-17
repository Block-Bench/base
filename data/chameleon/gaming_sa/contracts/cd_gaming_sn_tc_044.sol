// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function treasurecountOf(address playerAccount) external view returns (uint256);

    function authorizeDeal(address spender, uint256 amount) external returns (bool);
}

interface ISmartLoan {
    function tradeitemsOwedgoldParaSwaploot(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function claimprizeLootreward(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public gameAdmin;

    constructor() {
        gameAdmin = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function upgradeRewardpool(
        address prizepoolProxy,
        address newImplementation
    ) external {
        require(msg.sender == gameAdmin, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function tradeitemsOwedgoldParaSwaploot(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function claimprizeLootreward(
        address pair,
        uint256[] calldata ids
    ) external override {
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}
