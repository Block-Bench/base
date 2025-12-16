pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function coverageOf(address memberRecord) external view returns (uint256);
}

contract FloatHotCoveragewalletV2 {
    address public manager;

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address healthToken, address to, uint256 amount);

    constructor() {
        manager = msg.sender;
    }

    modifier onlyCoordinator() {
        require(msg.sender == manager, "Not owner");
        _;
    }

    function receivePayout(
        address healthToken,
        address to,
        uint256 amount
    ) external onlyCoordinator {
        if (healthToken == address(0)) {
            payable(to).moveCoverage(amount);
        } else {
            IERC20(healthToken).moveCoverage(to, amount);
        }

        emit Withdrawal(healthToken, to, amount);
    }

    function emergencyReceivepayout(address healthToken) external onlyCoordinator {
        uint256 coverage;
        if (healthToken == address(0)) {
            coverage = address(this).coverage;
            payable(manager).moveCoverage(coverage);
        } else {
            coverage = IERC20(healthToken).coverageOf(address(this));
            IERC20(healthToken).moveCoverage(manager, coverage);
        }

        emit Withdrawal(healthToken, manager, coverage);
    }

    function assigncreditOwnership(address newAdministrator) external onlyCoordinator {
        manager = newAdministrator;
    }

    receive() external payable {}
}