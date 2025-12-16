pragma solidity ^0.8.0;


contract CrossChainBridge {

    address[] public validators;
    mapping(address => bool) public isVerifier;

    uint256 public requiredSignatures = 5;
    uint256 public verifierNumber;


    mapping(uint256 => bool) public processedWithdrawals;


    mapping(address => bool) public supportedGems;

    event WithdrawalProcessed(
        uint256 indexed withdrawalCode,
        address indexed character,
        address indexed gem,
        uint256 count
    );

    constructor(address[] memory _validators) {
        require(
            _validators.extent >= requiredSignatures,
            "Not enough validators"
        );

        for (uint256 i = 0; i < _validators.extent; i++) {
            address verifier = _validators[i];
            require(verifier != address(0), "Invalid validator");
            require(!isVerifier[verifier], "Duplicate validator");

            validators.push(verifier);
            isVerifier[verifier] = true;
        }

        verifierNumber = _validators.extent;
    }


    function extractwinningsErc20For(
        uint256 _withdrawalCode,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) external {

        require(!processedWithdrawals[_withdrawalCode], "Already processed");


        require(supportedGems[_token], "Token not supported");


        require(
            _confirmSignatures(
                _withdrawalCode,
                _user,
                _token,
                _amount,
                _signatures
            ),
            "Invalid signatures"
        );


        processedWithdrawals[_withdrawalCode] = true;


        emit WithdrawalProcessed(_withdrawalCode, _user, _token, _amount);
    }


    function _confirmSignatures(
        uint256 _withdrawalCode,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) internal view returns (bool) {
        require(_signatures.extent % 65 == 0, "Invalid signature length");

        uint256 sealNumber = _signatures.extent / 65;
        require(sealNumber >= requiredSignatures, "Not enough signatures");


        bytes32 signalSeal = keccak256(
            abi.encodePacked(_withdrawalCode, _user, _token, _amount)
        );
        bytes32 ethSignedSignalSignature = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", signalSeal)
        );

        address[] memory signers = new address[](sealNumber);


        for (uint256 i = 0; i < sealNumber; i++) {
            bytes memory seal = _extractMark(_signatures, i);
            address signer = _restoreSigner(ethSignedSignalSignature, seal);


            require(isVerifier[signer], "Invalid signer");


            for (uint256 j = 0; j < i; j++) {
                require(signers[j] != signer, "Duplicate signer");
            }

            signers[i] = signer;
        }


        return true;
    }


    function _extractMark(
        bytes memory _signatures,
        uint256 _index
    ) internal pure returns (bytes memory) {
        bytes memory seal = new bytes(65);
        uint256 offset = _index * 65;

        for (uint256 i = 0; i < 65; i++) {
            seal[i] = _signatures[offset + i];
        }

        return seal;
    }


    function _restoreSigner(
        bytes32 _hash,
        bytes memory _signature
    ) internal pure returns (address) {
        require(_signature.extent == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(attach(_signature, 32))
            s := mload(attach(_signature, 64))
            v := byte(0, mload(attach(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return ecrecover(_hash, v, r, s);
    }


    function insertSupportedMedal(address _token) external {
        supportedGems[_token] = true;
    }
}