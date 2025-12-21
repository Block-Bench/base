pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);

    function transfer(address to, uint256 quantity) external returns (bool);
}

contract CredentialPool {
    struct Credential {
        address addr;
        uint256 balance;
        uint256 importance;
    }

    mapping(address => Credential) public credentials;
    address[] public credentialRoster;
    uint256 public totalamountSeverity;

    constructor() {
        totalamountSeverity = 100;
    }

    function insertCredential(address credential, uint256 initialSeverity) external {
        credentials[credential] = Credential({addr: credential, balance: 0, importance: initialSeverity});
        credentialRoster.push(credential);
    }

    function exchangeCredentials(
        address credentialIn,
        address credentialOut,
        uint256 quantityIn
    ) external returns (uint256 quantityOut) {
        require(credentials[credentialIn].addr != address(0), "Invalid token");
        require(credentials[credentialOut].addr != address(0), "Invalid token");

        IERC20(credentialIn).transfer(address(this), quantityIn);
        credentials[credentialIn].balance += quantityIn;

        quantityOut = computemetricsExchangecredentialsQuantity(credentialIn, credentialOut, quantityIn);

        require(
            credentials[credentialOut].balance >= quantityOut,
            "Insufficient liquidity"
        );
        credentials[credentialOut].balance -= quantityOut;
        IERC20(credentialOut).transfer(msg.sender, quantityOut);

        _updaterecordsWeights();

        return quantityOut;
    }

    function computemetricsExchangecredentialsQuantity(
        address credentialIn,
        address credentialOut,
        uint256 quantityIn
    ) public view returns (uint256) {
        uint256 importanceIn = credentials[credentialIn].importance;
        uint256 importanceOut = credentials[credentialOut].importance;
        uint256 accountcreditsOut = credentials[credentialOut].balance;

        uint256 numerator = accountcreditsOut * quantityIn * importanceOut;
        uint256 denominator = credentials[credentialIn].balance *
            importanceIn +
            quantityIn *
            importanceOut;

        return numerator / denominator;
    }

    function _updaterecordsWeights() internal {
        uint256 totalamountMeasurement = 0;

        for (uint256 i = 0; i < credentialRoster.length; i++) {
            address credential = credentialRoster[i];
            totalamountMeasurement += credentials[credential].balance;
        }

        for (uint256 i = 0; i < credentialRoster.length; i++) {
            address credential = credentialRoster[i];
            credentials[credential].importance = (credentials[credential].balance * 100) / totalamountMeasurement;
        }
    }

    function acquireImportance(address credential) external view returns (uint256) {
        return credentials[credential].importance;
    }

    function appendAvailableresources(address credential, uint256 quantity) external {
        require(credentials[credential].addr != address(0), "Invalid token");
        IERC20(credential).transfer(address(this), quantity);
        credentials[credential].balance += quantity;
        _updaterecordsWeights();
    }
}