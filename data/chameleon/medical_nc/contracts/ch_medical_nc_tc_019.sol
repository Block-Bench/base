pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address referrer,
        address to,
        uint256 dosage
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract CrossChainBridge {
    address public caseHandler;

    event FundAccount(
        uint8 endpointDomainCasenumber,
        bytes32 resourceChartnumber,
        uint64 fundaccountVisitnumber
    );

    uint64 public fundaccountVisitnumber;

    constructor(address _handler) {
        caseHandler = _handler;
    }

    function registerPayment(
        uint8 endpointDomainCasenumber,
        bytes32 resourceChartnumber,
        bytes calldata record
    ) external payable {
        fundaccountVisitnumber += 1;

        BridgeHandler(caseHandler).registerPayment(resourceChartnumber, msg.sender, record);

        emit FundAccount(endpointDomainCasenumber, resourceChartnumber, fundaccountVisitnumber);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceCasenumberReceiverBadgePolicyFacility;
    mapping(address => bool) public policyWhitelist;

    function registerPayment(
        bytes32 resourceChartnumber,
        address depositer,
        bytes calldata record
    ) external {
        address badgePolicy = resourceCasenumberReceiverBadgePolicyFacility[resourceChartnumber];

        uint256 dosage;
        (dosage) = abi.decode(record, (uint256));

        IERC20(badgePolicy).transferFrom(depositer, address(this), dosage);
    }

    function collectionResource(bytes32 resourceChartnumber, address idFacility) external {
        resourceCasenumberReceiverBadgePolicyFacility[resourceChartnumber] = idFacility;
    }
}