pragma solidity ^0.8.0;


contract CrossChainBridge {
    constructor() {
        owner = msg.sender;
    }

    address public owner;


    address[] public validators;
    mapping(address => bool) public isValidator;

    uint256 public requiredSignatures = 5;
    uint256 public validatorCount;


    mapping(uint256 => bool) public processedWithdrawals;


    mapping(address => bool) public supportedTokens;

    event WithdrawalProcessed(
        uint256 indexed withdrawalId,
        address indexed user,
        address indexed token,
        uint256 amount
    );

    constructor(address[] memory _validators) {
        require(
            _validators.length >= requiredSignatures,
            "Not enough validators"
        );

        for (uint256 i = 0; i < _validators.length; i++) {
            address validator = _validators[i];
            require(validator != address(0), "Invalid validator");
            require(!isValidator[validator], "Duplicate validator");

            validators.push(validator);
            isValidator[validator] = true;
        }

        validatorCount = _validators.length;
    }


    function withdrawERC20For(
        uint256 _withdrawalId,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) external {

        require(!processedWithdrawals[_withdrawalId], "Already processed");


        require(supportedTokens[_token], "Token not supported");


        require(
            _verifySignatures(
                _withdrawalId,
                _user,
                _token,
                _amount,
                _signatures
            ),
            "Invalid signatures"
        );


        processedWithdrawals[_withdrawalId] = true;


        emit WithdrawalProcessed(_withdrawalId, _user, _token, _amount);
    }


    function _verifySignatures(
        uint256 _withdrawalId,
        address _user,
        address _token,
        uint256 _amount,
        bytes memory _signatures
    ) internal view returns (bool) {
        require(_signatures.length % 65 == 0, "Invalid signature length");

        uint256 signatureCount = _signatures.length / 65;
        require(signatureCount >= requiredSignatures, "Not enough signatures");


        bytes32 messageHash = keccak256(
            abi.encodePacked(_withdrawalId, _user, _token, _amount)
        );
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        address[] memory signers = new address[](signatureCount);


        for (uint256 i = 0; i < signatureCount; i++) {
            bytes memory signature = _extractSignature(_signatures, i);
            address signer = _recoverSigner(ethSignedMessageHash, signature);


            require(isValidator[signer], "Invalid signer");


            for (uint256 j = 0; j < i; j++) {
                require(signers[j] != signer, "Duplicate signer");
            }

            signers[i] = signer;
        }


        return true;
    }


    function _extractSignature(
        bytes memory _signatures,
        uint256 _index
    ) internal pure returns (bytes memory) {
        bytes memory signature = new bytes(65);
        uint256 offset = _index * 65;

        for (uint256 i = 0; i < 65; i++) {
            signature[i] = _signatures[offset + i];
        }

        return signature;
    }


    function _recoverSigner(
        bytes32 _hash,
        bytes memory _signature
    ) internal pure returns (address) {
        require(_signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return ecrecover(_hash, v, r, s);
    }


    function addSupportedToken(address _token) external {
        supportedTokens[_token] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}