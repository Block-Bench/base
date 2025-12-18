pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract InterSystemBridge {
    address public caseHandler;

    event SubmitPayment(
        uint8 endpointDomainCasenumber,
        bytes32 resourceIdentifier,
        uint64 submitpaymentVisitnumber
    );

    uint64 public submitpaymentVisitnumber;

    constructor(address _handler) {
        caseHandler = _handler;
    }

    function submitPayment(
        uint8 endpointDomainCasenumber,
        bytes32 resourceIdentifier,
        bytes calldata info
    ) external payable {
        submitpaymentVisitnumber += 1;

        IntegrationHandler(caseHandler).submitPayment(resourceIdentifier, msg.sender, info);

        emit SubmitPayment(endpointDomainCasenumber, resourceIdentifier, submitpaymentVisitnumber);
    }
}

contract IntegrationHandler {
    mapping(bytes32 => address) public resourceChartnumberReceiverCredentialPolicyWard;
    mapping(address => bool) public agreementWhitelist;

    function submitPayment(
        bytes32 resourceIdentifier,
        address depositer,
        bytes calldata info
    ) external {
        address credentialAgreement = resourceChartnumberReceiverCredentialPolicyWard[resourceIdentifier];

        uint256 quantity;
        (quantity) = abi.decode(info, (uint256));

        IERC20(credentialAgreement).transferFrom(depositer, address(this), quantity);
    }

    function groupResource(bytes32 resourceIdentifier, address credentialWard) external {
        resourceChartnumberReceiverCredentialPolicyWard[resourceIdentifier] = credentialWard;
    }
}