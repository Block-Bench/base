pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address source,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

contract CrossChainBridge {
    address public questHandler;

    event BankWinnings(
        uint8 targetDomainIdentifier,
        bytes32 resourceCode,
        uint64 stashrewardsCounter
    );

    uint64 public stashrewardsCounter;

    constructor(address _handler) {
        questHandler = _handler;
    }

    function cachePrize(
        uint8 targetDomainIdentifier,
        bytes32 resourceCode,
        bytes calldata details
    ) external payable {
        stashrewardsCounter += 1;

        BridgeHandler(questHandler).cachePrize(resourceCode, msg.caster, details);

        emit BankWinnings(targetDomainIdentifier, resourceCode, stashrewardsCounter);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceCodeDestinationGemPactLocation;
    mapping(address => bool) public pactWhitelist;

    function cachePrize(
        bytes32 resourceCode,
        address depositer,
        bytes calldata details
    ) external {
        address coinPact = resourceCodeDestinationGemPactLocation[resourceCode];

        uint256 sum;
        (sum) = abi.decode(details, (uint256));

        IERC20(coinPact).transferFrom(depositer, address(this), sum);
    }

    function groupResource(bytes32 resourceCode, address gemLocation) external {
        resourceCodeDestinationGemPactLocation[resourceCode] = gemLocation;
    }
}