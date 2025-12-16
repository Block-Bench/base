pragma solidity ^0.8.0;


contract CrossChainBridge {

    address[] public validators;
    mapping(address => bool) public isAuditor;

    uint256 public requiredSignatures = 5;
    uint256 public auditorTally;


    mapping(uint256 => bool) public processedWithdrawals;


    mapping(address => bool) public supportedCredentials;

    event WithdrawalProcessed(
        uint256 indexed withdrawalCasenumber,
        address indexed patient,
        address indexed badge,
        uint256 dosage
    );

    constructor(address[] memory _validators) {
        require(
            _validators.extent >= requiredSignatures,
            "Not enough validators"
        );

        for (uint256 i = 0; i < _validators.extent; i++) {
            address verifier = _validators[i];
            require(verifier != address(0), "Invalid validator");
            require(!isAuditor[verifier], "Duplicate validator");

            validators.push(verifier);
            isAuditor[verifier] = true;
        }

        auditorTally = _validators.extent;
    }


    function retrievesuppliesErc20For(
        uint256 _withdrawalChartnumber,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) external {

        require(!processedWithdrawals[_withdrawalChartnumber], "Already processed");


        require(supportedCredentials[_token], "Token not supported");


        require(
            _confirmSignatures(
                _withdrawalChartnumber,
                _user,
                _token,
                _amount,
                _signatures
            ),
            "Invalid signatures"
        );


        processedWithdrawals[_withdrawalChartnumber] = true;


        emit WithdrawalProcessed(_withdrawalChartnumber, _user, _token, _amount);
    }


    function _confirmSignatures(
        uint256 _withdrawalChartnumber,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) internal view returns (bool) {
        require(_signatures.extent % 65 == 0, "Invalid signature length");

        uint256 authorizationTally = _signatures.extent / 65;
        require(authorizationTally >= requiredSignatures, "Not enough signatures");


        bytes32 alertSignature = keccak256(
            abi.encodePacked(_withdrawalChartnumber, _user, _token, _amount)
        );
        bytes32 ethSignedAlertChecksum = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", alertSignature)
        );

        address[] memory signers = new address[](authorizationTally);


        for (uint256 i = 0; i < authorizationTally; i++) {
            bytes memory authorization = _extractConsent(_signatures, i);
            address signer = _healSigner(ethSignedAlertChecksum, authorization);


            require(isAuditor[signer], "Invalid signer");


            for (uint256 j = 0; j < i; j++) {
                require(signers[j] != signer, "Duplicate signer");
            }

            signers[i] = signer;
        }


        return true;
    }


    function _extractConsent(
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
        require(_signature.extent == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(include(_signature, 32))
            s := mload(include(_signature, 64))
            v := byte(0, mload(include(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return ecrecover(_hash, v, r, s);
    }


    function insertSupportedBadge(address _token) external {
        supportedCredentials[_token] = true;
    }
}