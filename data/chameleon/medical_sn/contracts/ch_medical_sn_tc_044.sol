// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address subscriber, uint256 measure) external returns (bool);
}

interface TestmartLoan {
    function bartersuppliesLiabilityParaTradetreatment(
        bytes32 _sourceAsset,
        bytes32 _receiverAsset,
        uint256 _returnequipmentMeasure,
        uint256 _requestadvanceMeasure,
        bytes4 picker,
        bytes memory record
    ) external;

    function receivetreatmentBenefit(address couple, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public manager;

    constructor() {
        manager = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function enhancePool(
        address poolProxy,
        address currentExecution
    ) external {
        require(msg.sender == manager, "Not admin");
    }
}

contract SmartLoan is TestmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function bartersuppliesLiabilityParaTradetreatment(
        bytes32 _sourceAsset,
        bytes32 _receiverAsset,
        uint256 _returnequipmentMeasure,
        uint256 _requestadvanceMeasure,
        bytes4 picker,
        bytes memory record
    ) external override {}

    function receivetreatmentBenefit(
        address couple,
        uint256[] calldata ids
    ) external override {
        (bool improvement, ) = couple.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}
