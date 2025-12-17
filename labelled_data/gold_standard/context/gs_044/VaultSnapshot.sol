function healthFactor(Data memory data) internal pure returns (uint256) {
    uint256 liquidationThreshold = data.lstCollateralAmountInEth * data.liquidationThreshold / 10_000;
    if (data.wethDebtAmount == 0) return type(uint256).max;
    return liquidationThreshold * 1e18 / data.wethDebtAmount;
}

function borrowAmountForLoopInEth(Data memory data) internal pure returns (uint256) {
    uint256 maxBorrowAmount = data.lstCollateralAmountInEth * data.ltv / 10_000;
    if (maxBorrowAmount <= data.wethDebtAmount) return 0;
    
    uint256 targetAmount = data.lstCollateralAmountInEth * data.liquidationThreshold / 10_000 / data.targetHealthFactor;
    uint256 amount = targetAmount > data.wethDebtAmount ? targetAmount - data.wethDebtAmount : 0;
    
    return amount > maxBorrowAmount - data.wethDebtAmount ? maxBorrowAmount - data.wethDebtAmount : amount;
}