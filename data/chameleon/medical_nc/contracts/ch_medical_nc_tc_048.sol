pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 units
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public completeBorrows;
    uint256 public completeBackup;

    event IssueCredential(address creator, uint256 generaterecordQuantity, uint256 issuecredentialCredentials);
    event ConvertBenefits(address redeemer, uint256 convertbenefitsUnits, uint256 convertbenefitsIds);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeFrequency() public view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }

        uint256 cash = underlying.balanceOf(address(this));

        uint256 cumulativeUnderlying = cash + completeBorrows - completeBackup;

        return (cumulativeUnderlying * 1e18) / totalSupply;
    }

    function createPrescription(uint256 generaterecordQuantity) external returns (uint256) {
        require(generaterecordQuantity > 0, "Zero mint");

        uint256 exchangeFrequencyMantissa = exchangeFrequency();

        uint256 issuecredentialCredentials = (generaterecordQuantity * 1e18) / exchangeFrequencyMantissa;

        totalSupply += issuecredentialCredentials;
        balanceOf[msg.provider] += issuecredentialCredentials;

        underlying.transferFrom(msg.provider, address(this), generaterecordQuantity);

        emit IssueCredential(msg.provider, generaterecordQuantity, issuecredentialCredentials);
        return issuecredentialCredentials;
    }

    function cashOutCoverage(uint256 convertbenefitsIds) external returns (uint256) {
        require(balanceOf[msg.provider] >= convertbenefitsIds, "Insufficient balance");

        uint256 exchangeFrequencyMantissa = exchangeFrequency();

        uint256 convertbenefitsUnits = (convertbenefitsIds * exchangeFrequencyMantissa) / 1e18;

        balanceOf[msg.provider] -= convertbenefitsIds;
        totalSupply -= convertbenefitsIds;

        underlying.transfer(msg.provider, convertbenefitsUnits);

        emit ConvertBenefits(msg.provider, convertbenefitsUnits, convertbenefitsIds);
        return convertbenefitsUnits;
    }

    function fundsOfUnderlying(
        address profile
    ) external view returns (uint256) {
        uint256 exchangeFrequencyMantissa = exchangeFrequency();

        return (balanceOf[profile] * exchangeFrequencyMantissa) / 1e18;
    }
}