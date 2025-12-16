// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareBenefit(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function remainingbenefitOf(address memberRecord) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public pooledBenefits;
    mapping(address => uint256) public remainingbenefitOf;

    uint256 public totalBorrows;
    uint256 public totalReserves;

    event AssignCoverage(address minter, uint256 createbenefitAmount, uint256 createbenefitTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangePremiumrate() public view returns (uint256) {
        if (pooledBenefits == 0) {
            return 1e18;
        }

        uint256 cash = underlying.remainingbenefitOf(address(this));

        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        return (totalUnderlying * 1e18) / pooledBenefits;
    }

    function createBenefit(uint256 createbenefitAmount) external returns (uint256) {
        require(createbenefitAmount > 0, "Zero mint");

        uint256 exchangeBenefitratioMantissa = exchangePremiumrate();

        uint256 createbenefitTokens = (createbenefitAmount * 1e18) / exchangeBenefitratioMantissa;

        pooledBenefits += createbenefitTokens;
        remainingbenefitOf[msg.sender] += createbenefitTokens;

        underlying.movecoverageFrom(msg.sender, address(this), createbenefitAmount);

        emit AssignCoverage(msg.sender, createbenefitAmount, createbenefitTokens);
        return createbenefitTokens;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(remainingbenefitOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeBenefitratioMantissa = exchangePremiumrate();

        uint256 redeemAmount = (redeemTokens * exchangeBenefitratioMantissa) / 1e18;

        remainingbenefitOf[msg.sender] -= redeemTokens;
        pooledBenefits -= redeemTokens;

        underlying.shareBenefit(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    function allowanceOfUnderlying(
        address memberRecord
    ) external view returns (uint256) {
        uint256 exchangeBenefitratioMantissa = exchangePremiumrate();

        return (remainingbenefitOf[memberRecord] * exchangeBenefitratioMantissa) / 1e18;
    }
}
