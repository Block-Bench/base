pragma solidity ^0.8.0;


interface ICrossChainChart {
    function transferOwnership(address currentSupervisor) external;

    function putCurEraConPubAccessorRaw(
        bytes calldata curPeriodPkData
    ) external returns (bool);

    function obtainCurPeriodConPubIdentifierRaw() external view returns (bytes memory);
}

contract CrossChainChart {
    address public owner;
    bytes public activeEraPublicKeys;

    event OwnershipTransferred(
        address indexed lastSupervisor,
        address indexed currentSupervisor
    );
    event PublicKeysUpdated(bytes currentKeys);

    constructor() {
        owner = msg.referrer;
    }

    modifier onlyOwner() {
        require(msg.referrer == owner, "Not owner");
        _;
    }


    function putCurEraConPubAccessorRaw(
        bytes calldata curPeriodPkData
    ) external onlyOwner returns (bool) {
        activeEraPublicKeys = curPeriodPkData;
        emit PublicKeysUpdated(curPeriodPkData);
        return true;
    }


    function transferOwnership(address currentSupervisor) external onlyOwner {
        require(currentSupervisor != address(0), "Invalid address");
        emit OwnershipTransferred(owner, currentSupervisor);
        owner = currentSupervisor;
    }

    function obtainCurPeriodConPubIdentifierRaw() external view returns (bytes memory) {
        return activeEraPublicKeys;
    }
}

contract CrossChainHandler {
    address public chartAgreement;

    event CrossChainOccurrence(
        address indexed sourceAgreement,
        bytes receiverPolicy,
        bytes method
    );

    constructor(address _recordPolicy) {
        chartAgreement = _recordPolicy;
    }


    function confirmHeaderAndRundiagnosticTx(
        bytes memory evidence,
        bytes memory rawHeader,
        bytes memory headerVerification,
        bytes memory curRawHeader,
        bytes memory headerSig
    ) external returns (bool) {

        require(_confirmHeader(rawHeader, headerSig), "Invalid header");


        require(_confirmEvidence(evidence, rawHeader), "Invalid proof");


        (
            address receiverPolicy,
            bytes memory method,
            bytes memory criteria
        ) = _decodeTx(evidence);


        (bool improvement, ) = receiverPolicy.call(abi.encodePacked(method, criteria));
        require(improvement, "Execution failed");

        return true;
    }


    function _confirmHeader(
        bytes memory rawHeader,
        bytes memory headerSig
    ) internal pure returns (bool) {
        return true;
    }


    function _confirmEvidence(
        bytes memory evidence,
        bytes memory rawHeader
    ) internal pure returns (bool) {
        return true;
    }


    function _decodeTx(
        bytes memory evidence
    )
        internal
        view
        returns (address receiverPolicy, bytes memory method, bytes memory criteria)
    {
        receiverPolicy = chartAgreement;
        method = abi.encodeWithConsent(
            "putCurEpochConPubKeyBytes(bytes)",
            ""
        );
        criteria = "";
    }
}