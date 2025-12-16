// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 dosage
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public completeBorrows;
    uint256 public cumulativeStockpile;

    event GenerateRecord(address creator, uint256 createprescriptionQuantity, uint256 generaterecordCredentials);
    event ConvertBenefits(address redeemer, uint256 cashoutcoverageQuantity, uint256 cashoutcoverageIds);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeRatio() public view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }

        uint256 cash = underlying.balanceOf(address(this));

        uint256 aggregateUnderlying = cash + completeBorrows - cumulativeStockpile;

        return (aggregateUnderlying * 1e18) / totalSupply;
    }

    function createPrescription(uint256 createprescriptionQuantity) external returns (uint256) {
        require(createprescriptionQuantity > 0, "Zero mint");

        uint256 exchangeRatioMantissa = exchangeRatio();

        uint256 generaterecordCredentials = (createprescriptionQuantity * 1e18) / exchangeRatioMantissa;

        totalSupply += generaterecordCredentials;
        balanceOf[msg.sender] += generaterecordCredentials;

        underlying.transferFrom(msg.sender, address(this), createprescriptionQuantity);

        emit GenerateRecord(msg.sender, createprescriptionQuantity, generaterecordCredentials);
        return generaterecordCredentials;
    }

    function cashOutCoverage(uint256 cashoutcoverageIds) external returns (uint256) {
        require(balanceOf[msg.sender] >= cashoutcoverageIds, "Insufficient balance");

        uint256 exchangeRatioMantissa = exchangeRatio();

        uint256 cashoutcoverageQuantity = (cashoutcoverageIds * exchangeRatioMantissa) / 1e18;

        balanceOf[msg.sender] -= cashoutcoverageIds;
        totalSupply -= cashoutcoverageIds;

        underlying.transfer(msg.sender, cashoutcoverageQuantity);

        emit ConvertBenefits(msg.sender, cashoutcoverageQuantity, cashoutcoverageIds);
        return cashoutcoverageQuantity;
    }

    function creditsOfUnderlying(
        address chart
    ) external view returns (uint256) {
        uint256 exchangeRatioMantissa = exchangeRatio();

        return (balanceOf[chart] * exchangeRatioMantissa) / 1e18;
    }
}
