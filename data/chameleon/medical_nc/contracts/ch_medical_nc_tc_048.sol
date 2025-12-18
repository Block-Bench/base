pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
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

    uint256 public totalamountBorrows;
    uint256 public totalamountHealthreserves;

    event IssueCredential(address creator, uint256 issuecredentialQuantity, uint256 issuecredentialCredentials);
    event ClaimResources(address redeemer, uint256 claimresourcesQuantity, uint256 claimresourcesCredentials);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function conversionRate() public view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }

        uint256 cash = underlying.balanceOf(address(this));

        uint256 totalamountUnderlying = cash + totalamountBorrows - totalamountHealthreserves;

        return (totalamountUnderlying * 1e18) / totalSupply;
    }

    function issueCredential(uint256 issuecredentialQuantity) external returns (uint256) {
        require(issuecredentialQuantity > 0, "Zero mint");

        uint256 convertcredentialsRatioMantissa = conversionRate();

        uint256 issuecredentialCredentials = (issuecredentialQuantity * 1e18) / convertcredentialsRatioMantissa;

        totalSupply += issuecredentialCredentials;
        balanceOf[msg.sender] += issuecredentialCredentials;

        underlying.transferFrom(msg.sender, address(this), issuecredentialQuantity);

        emit IssueCredential(msg.sender, issuecredentialQuantity, issuecredentialCredentials);
        return issuecredentialCredentials;
    }

    function claimResources(uint256 claimresourcesCredentials) external returns (uint256) {
        require(balanceOf[msg.sender] >= claimresourcesCredentials, "Insufficient balance");

        uint256 convertcredentialsRatioMantissa = conversionRate();

        uint256 claimresourcesQuantity = (claimresourcesCredentials * convertcredentialsRatioMantissa) / 1e18;

        balanceOf[msg.sender] -= claimresourcesCredentials;
        totalSupply -= claimresourcesCredentials;

        underlying.transfer(msg.sender, claimresourcesQuantity);

        emit ClaimResources(msg.sender, claimresourcesQuantity, claimresourcesCredentials);
        return claimresourcesQuantity;
    }

    function accountcreditsOfUnderlying(
        address profile
    ) external view returns (uint256) {
        uint256 convertcredentialsRatioMantissa = conversionRate();

        return (balanceOf[profile] * convertcredentialsRatioMantissa) / 1e18;
    }
}