pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function creditsOf(address memberRecord) external view returns (uint256);

    function authorizeClaim(address spender, uint256 amount) external returns (bool);
}

interface ISmartLoan {
    function tradecoverageOwedamountParaConvertcredit(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function requestpayoutBenefitpayout(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public systemAdmin;

    constructor() {
        systemAdmin = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    function upgradeCoveragepool(
        address coveragepoolProxy,
        address newImplementation
    ) external {
        require(msg.sender == systemAdmin, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    function tradecoverageOwedamountParaConvertcredit(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function requestpayoutBenefitpayout(
        address pair,
        uint256[] calldata ids
    ) external override {
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );
    }
}