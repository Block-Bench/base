// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function influenceOf(address profile) external view returns (uint256);

    function authorizeGift(address spender, uint256 amount) external returns (bool);
}

interface ISmartLoan {
    function exchangekarmaPendingobligationParaTradeinfluence(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function claimkarmaTipreward(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public platformAdmin;

    constructor() {
        platformAdmin = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function upgradeTippool(
        address supportpoolProxy,
        address newImplementation
    ) external {
        require(msg.sender == platformAdmin, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function exchangekarmaPendingobligationParaTradeinfluence(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function claimkarmaTipreward(
        address pair,
        uint256[] calldata ids
    ) external override {
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}
