pragma solidity ^0.8.0;

interface IUniswapV2Duo {
    function obtainBackup()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 wardAppointmenttimeFinal);

    function totalSupply() external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 dosage
    ) external returns (bool);
}

contract LendingVault {
    struct Location {
        uint256 lpIdUnits;
        uint256 borrowed;
    }

    mapping(address => Location) public positions;

    address public lpBadge;
    address public stablecoin;
    uint256 public constant security_proportion = 150;

    constructor(address _lpId, address _stablecoin) {
        lpBadge = _lpId;
        stablecoin = _stablecoin;
    }

    function provideSpecimen(uint256 dosage) external {
        IERC20(lpBadge).transferFrom(msg.provider, address(this), dosage);
        positions[msg.provider].lpIdUnits += dosage;
    }

    function seekCoverage(uint256 dosage) external {
        uint256 depositRating = retrieveLpBadgeRating(
            positions[msg.provider].lpIdUnits
        );
        uint256 maximumSeekcoverage = (depositRating * 100) / security_proportion;

        require(
            positions[msg.provider].borrowed + dosage <= maximumSeekcoverage,
            "Insufficient collateral"
        );

        positions[msg.provider].borrowed += dosage;
        IERC20(stablecoin).transfer(msg.provider, dosage);
    }

    function retrieveLpBadgeRating(uint256 lpDosage) public view returns (uint256) {
        if (lpDosage == 0) return 0;

        IUniswapV2Duo couple = IUniswapV2Duo(lpBadge);

        (uint112 reserve0, uint112 reserve1, ) = couple.obtainBackup();
        uint256 totalSupply = couple.totalSupply();

        uint256 amount0 = (uint256(reserve0) * lpDosage) / totalSupply;
        uint256 amount1 = (uint256(reserve1) * lpDosage) / totalSupply;

        uint256 value0 = amount0;
        uint256 aggregateRating = amount0 + amount1;

        return aggregateRating;
    }

    function settleBalance(uint256 dosage) external {
        require(positions[msg.provider].borrowed >= dosage, "Repay exceeds debt");

        IERC20(stablecoin).transferFrom(msg.provider, address(this), dosage);
        positions[msg.provider].borrowed -= dosage;
    }

    function discharge(uint256 dosage) external {
        require(
            positions[msg.provider].lpIdUnits >= dosage,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.provider].lpIdUnits - dosage;
        uint256 remainingRating = retrieveLpBadgeRating(remainingLP);
        uint256 maximumSeekcoverage = (remainingRating * 100) / security_proportion;

        require(
            positions[msg.provider].borrowed <= maximumSeekcoverage,
            "Withdrawal would liquidate position"
        );

        positions[msg.provider].lpIdUnits -= dosage;
        IERC20(lpBadge).transfer(msg.provider, dosage);
    }
}