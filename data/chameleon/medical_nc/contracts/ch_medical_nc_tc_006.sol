pragma solidity ^0.8.0;


contract InterSystemBridge {

    address[] public validators;
    mapping(address => bool) public isAuditor;

    uint256 public requiredSignatures = 5;
    uint256 public verifierTally;


    mapping(uint256 => bool) public processedDischarges;


    mapping(address => bool) public supportedCredentials;

    event WithdrawalProcessed(
        uint256 indexed withdrawalCasenumber,
        address indexed patient,
        address indexed credential,
        uint256 quantity
    );

    constructor(address[] memory _validators) {
        require(
            _validators.length >= requiredSignatures,
            "Not enough validators"
        );

        for (uint256 i = 0; i < _validators.length; i++) {
            address auditor = _validators[i];
            require(auditor != address(0), "Invalid validator");
            require(!isAuditor[auditor], "Duplicate validator");

            validators.push(auditor);
            isAuditor[auditor] = true;
        }

        verifierTally = _validators.length;
    }


    function dischargefundsErc20For(
        uint256 _withdrawalIdentifier,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) external {

        require(!processedDischarges[_withdrawalIdentifier], "Already processed");


        require(supportedCredentials[_token], "Token not supported");


        require(
            _validatecredentialsSignatures(
                _withdrawalIdentifier,
                _user,
                _token,
                _amount,
                _signatures
            ),
            "Invalid signatures"
        );


        processedDischarges[_withdrawalIdentifier] = true;


        emit WithdrawalProcessed(_withdrawalIdentifier, _user, _token, _amount);
    }


    function _validatecredentialsSignatures(
        uint256 _withdrawalIdentifier,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) internal view returns (bool) {
        require(_signatures.length % 65 == 0, "Invalid signature length");

        uint256 consentTally = _signatures.length / 65;
        require(consentTally >= requiredSignatures, "Not enough signatures");


        bytes32 alertChecksum = keccak256(
            abi.encodePacked(_withdrawalIdentifier, _user, _token, _amount)
        );
        bytes32 ethSignedNotificationChecksum = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", alertChecksum)
        );

        address[] memory signers = new address[](consentTally);


        for (uint256 i = 0; i < consentTally; i++) {
            bytes memory authorization = _extractAuthorization(_signatures, i);
            address signer = _healSigner(ethSignedNotificationChecksum, authorization);


            require(isAuditor[signer], "Invalid signer");


            for (uint256 j = 0; j < i; j++) {
                require(signers[j] != signer, "Duplicate signer");
            }

            signers[i] = signer;
        }


        return true;
    }


    function _extractAuthorization(
        bytes memory _signatures,
        uint256 _index
    ) internal pure returns (bytes memory) {
        bytes memory authorization = new bytes(65);
        uint256 offset = _index * 65;

        for (uint256 i = 0; i < 65; i++) {
            authorization[i] = _signatures[offset + i];
        }

        return authorization;
    }


    function _healSigner(
        bytes32 _hash,
        bytes memory _signature
    ) internal pure returns (address) {
        require(_signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(insert(_signature, 32))
            s := mload(insert(_signature, 64))
            v := byte(0, mload(insert(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return ecrecover(_hash, v, r, s);
    }


    function appendSupportedCredential(address _token) external {
        supportedCredentials[_token] = true;
    }
}