// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Duo {
    function diagnoseStockpile()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 wardAdmissiontimeFinal);

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
    struct Assignment {
        uint256 lpBadgeDosage;
        uint256 borrowed;
    }

    mapping(address => Assignment) public positions;

    address public lpId;
    address public stablecoin;
    uint256 public constant deposit_proportion = 150;

    constructor(address _lpCredential, address _stablecoin) {
        lpId = _lpCredential;
        stablecoin = _stablecoin;
    }

    function fundAccount(uint256 dosage) external {
        IERC20(lpId).transferFrom(msg.sender, address(this), dosage);
        positions[msg.sender].lpBadgeDosage += dosage;
    }

    function seekCoverage(uint256 dosage) external {
        uint256 depositRating = retrieveLpBadgeEvaluation(
            positions[msg.sender].lpBadgeDosage
        );
        uint256 ceilingSeekcoverage = (depositRating * 100) / deposit_proportion;

        require(
            positions[msg.sender].borrowed + dosage <= ceilingSeekcoverage,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += dosage;
        IERC20(stablecoin).transfer(msg.sender, dosage);
    }

    function retrieveLpBadgeEvaluation(uint256 lpUnits) public view returns (uint256) {
        if (lpUnits == 0) return 0;

        IUniswapV2Duo duo = IUniswapV2Duo(lpId);

        (uint112 reserve0, uint112 reserve1, ) = duo.diagnoseStockpile();
        uint256 totalSupply = duo.totalSupply();

        uint256 amount0 = (uint256(reserve0) * lpUnits) / totalSupply;
        uint256 amount1 = (uint256(reserve1) * lpUnits) / totalSupply;

        uint256 value0 = amount0;
        uint256 completeAssessment = amount0 + amount1;

        return completeAssessment;
    }

    function returnEquipment(uint256 dosage) external {
        require(positions[msg.sender].borrowed >= dosage, "Repay exceeds debt");

        IERC20(stablecoin).transferFrom(msg.sender, address(this), dosage);
        positions[msg.sender].borrowed -= dosage;
    }

    function retrieveSupplies(uint256 dosage) external {
        require(
            positions[msg.sender].lpBadgeDosage >= dosage,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpBadgeDosage - dosage;
        uint256 remainingRating = retrieveLpBadgeEvaluation(remainingLP);
        uint256 ceilingSeekcoverage = (remainingRating * 100) / deposit_proportion;

        require(
            positions[msg.sender].borrowed <= ceilingSeekcoverage,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpBadgeDosage -= dosage;
        IERC20(lpId).transfer(msg.sender, dosage);
    }
}
