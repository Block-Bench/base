pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function coverageOf(address memberRecord) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public reserveTotal;
    mapping(address => uint256) public coverageOf;

    uint256 public totalBorrows;
    uint256 public totalReserves;

    event IssueCoverage(address minter, uint256 createbenefitAmount, uint256 createbenefitTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeBenefitratio() public view returns (uint256) {
        if (reserveTotal == 0) {
            return 1e18;
        }

        uint256 cash = underlying.coverageOf(address(this));

        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        return (totalUnderlying * 1e18) / reserveTotal;
    }

    function issueCoverage(uint256 createbenefitAmount) external returns (uint256) {
        require(createbenefitAmount > 0, "Zero mint");

        uint256 exchangeCoveragerateMantissa = exchangeBenefitratio();

        uint256 createbenefitTokens = (createbenefitAmount * 1e18) / exchangeCoveragerateMantissa;

        reserveTotal += createbenefitTokens;
        coverageOf[msg.sender] += createbenefitTokens;

        underlying.transferbenefitFrom(msg.sender, address(this), createbenefitAmount);

        emit IssueCoverage(msg.sender, createbenefitAmount, createbenefitTokens);
        return createbenefitTokens;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(coverageOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeCoveragerateMantissa = exchangeBenefitratio();

        uint256 redeemAmount = (redeemTokens * exchangeCoveragerateMantissa) / 1e18;

        coverageOf[msg.sender] -= redeemTokens;
        reserveTotal -= redeemTokens;

        underlying.assignCredit(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    function creditsOfUnderlying(
        address memberRecord
    ) external view returns (uint256) {
        uint256 exchangeCoveragerateMantissa = exchangeBenefitratio();

        return (coverageOf[memberRecord] * exchangeCoveragerateMantissa) / 1e18;
    }
}