pragma solidity ^0.8.0;

interface IUniswapV2Duo {
    function obtainHealthreserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 wardAppointmenttimeFinal);

    function totalSupply() external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);
}

contract HealthcareFinanceVault {
    struct CarePosition {
        uint256 lpCredentialQuantity;
        uint256 advancedAmount;
    }

    mapping(address => CarePosition) public positions;

    address public lpCredential;
    address public stablecoin;
    uint256 public constant securitydeposit_factor = 150;

    constructor(address _lpCredential, address _stablecoin) {
        lpCredential = _lpCredential;
        stablecoin = _stablecoin;
    }

    function submitPayment(uint256 quantity) external {
        IERC20(lpCredential).transferFrom(msg.sender, address(this), quantity);
        positions[msg.sender].lpCredentialQuantity += quantity;
    }

    function requestAdvance(uint256 quantity) external {
        uint256 securitydepositMeasurement = obtainLpCredentialMeasurement(
            positions[msg.sender].lpCredentialQuantity
        );
        uint256 ceilingRequestadvance = (securitydepositMeasurement * 100) / securitydeposit_factor;

        require(
            positions[msg.sender].advancedAmount + quantity <= ceilingRequestadvance,
            "Insufficient collateral"
        );

        positions[msg.sender].advancedAmount += quantity;
        IERC20(stablecoin).transfer(msg.sender, quantity);
    }

    function obtainLpCredentialMeasurement(uint256 lpQuantity) public view returns (uint256) {
        if (lpQuantity == 0) return 0;

        IUniswapV2Duo duo = IUniswapV2Duo(lpCredential);

        (uint112 reserve0, uint112 reserve1, ) = duo.obtainHealthreserves();
        uint256 totalSupply = duo.totalSupply();

        uint256 amount0 = (uint256(reserve0) * lpQuantity) / totalSupply;
        uint256 amount1 = (uint256(reserve1) * lpQuantity) / totalSupply;

        uint256 value0 = amount0;
        uint256 totalamountMeasurement = amount0 + amount1;

        return totalamountMeasurement;
    }

    function settleBalance(uint256 quantity) external {
        require(positions[msg.sender].advancedAmount >= quantity, "Repay exceeds debt");

        IERC20(stablecoin).transferFrom(msg.sender, address(this), quantity);
        positions[msg.sender].advancedAmount -= quantity;
    }

    function dischargeFunds(uint256 quantity) external {
        require(
            positions[msg.sender].lpCredentialQuantity >= quantity,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpCredentialQuantity - quantity;
        uint256 remainingMeasurement = obtainLpCredentialMeasurement(remainingLP);
        uint256 ceilingRequestadvance = (remainingMeasurement * 100) / securitydeposit_factor;

        require(
            positions[msg.sender].advancedAmount <= ceilingRequestadvance,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpCredentialQuantity -= quantity;
        IERC20(lpCredential).transfer(msg.sender, quantity);
    }
}