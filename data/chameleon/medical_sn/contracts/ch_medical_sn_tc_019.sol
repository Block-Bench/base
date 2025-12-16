// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address referrer,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

contract CrossChainBridge {
    address public caseHandler;

    event Admit(
        uint8 targetDomainIdentifier,
        bytes32 resourceChartnumber,
        uint64 registerpaymentSequence
    );

    uint64 public registerpaymentSequence;

    constructor(address _handler) {
        caseHandler = _handler;
    }

    function submitPayment(
        uint8 targetDomainIdentifier,
        bytes32 resourceChartnumber,
        bytes calldata record
    ) external payable {
        registerpaymentSequence += 1;

        BridgeHandler(caseHandler).submitPayment(resourceChartnumber, msg.provider, record);

        emit Admit(targetDomainIdentifier, resourceChartnumber, registerpaymentSequence);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIdentifierReceiverCredentialAgreementLocation;
    mapping(address => bool) public agreementWhitelist;

    function submitPayment(
        bytes32 resourceChartnumber,
        address depositer,
        bytes calldata record
    ) external {
        address idAgreement = resourceIdentifierReceiverCredentialAgreementLocation[resourceChartnumber];

        uint256 measure;
        (measure) = abi.decode(record, (uint256));

        IERC20(idAgreement).transferFrom(depositer, address(this), measure);
    }

    function groupResource(bytes32 resourceChartnumber, address badgeWard) external {
        resourceIdentifierReceiverCredentialAgreementLocation[resourceChartnumber] = badgeWard;
    }
}
