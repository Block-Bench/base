// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function creditsOf(address patientAccount) external view returns (uint256);

    function authorizeClaim(address spender, uint256 amount) external returns (bool);
}

interface ISmartLoan {
    function tradecoverageUnpaidpremiumParaExchangebenefit(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function fileclaimCoveragereward(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public claimsAdmin;

    constructor() {
        claimsAdmin = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function upgradeInsurancepool(
        address benefitpoolProxy,
        address newImplementation
    ) external {
        require(msg.sender == claimsAdmin, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function tradecoverageUnpaidpremiumParaExchangebenefit(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function fileclaimCoveragereward(
        address pair,
        uint256[] calldata ids
    ) external override {
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}
