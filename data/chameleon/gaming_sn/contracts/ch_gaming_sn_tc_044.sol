// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address consumer, uint256 measure) external returns (bool);
}

interface TestmartLoan {
    function tradetreasureLiabilityParaBartergoods(
        bytes32 _sourceAsset,
        bytes32 _destinationAsset,
        uint256 _settledebtQuantity,
        uint256 _requestloanSum,
        bytes4 chooser,
        bytes memory info
    ) external;

    function obtainrewardBounty(address couple, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public serverOp;

    constructor() {
        serverOp = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function enhancePool(
        address poolProxy,
        address updatedRealization
    ) external {
        require(msg.sender == serverOp, "Not admin");
    }
}

contract SmartLoan is TestmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function tradetreasureLiabilityParaBartergoods(
        bytes32 _sourceAsset,
        bytes32 _destinationAsset,
        uint256 _settledebtQuantity,
        uint256 _requestloanSum,
        bytes4 chooser,
        bytes memory info
    ) external override {}

    function obtainrewardBounty(
        address couple,
        uint256[] calldata ids
    ) external override {
        (bool win, ) = couple.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}
