// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address source,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract CrossChainBridge {
    address public eventHandler;

    event StashRewards(
        uint8 endpointDomainTag,
        bytes32 resourceCode,
        uint64 storelootCounter
    );

    uint64 public storelootCounter;

    constructor(address _handler) {
        eventHandler = _handler;
    }

    function addTreasure(
        uint8 endpointDomainTag,
        bytes32 resourceCode,
        bytes calldata info
    ) external payable {
        storelootCounter += 1;

        BridgeHandler(eventHandler).addTreasure(resourceCode, msg.sender, info);

        emit StashRewards(endpointDomainTag, resourceCode, storelootCounter);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIdentifierTargetMedalPactRealm;
    mapping(address => bool) public pactWhitelist;

    function addTreasure(
        bytes32 resourceCode,
        address depositer,
        bytes calldata info
    ) external {
        address crystalPact = resourceIdentifierTargetMedalPactRealm[resourceCode];

        uint256 sum;
        (sum) = abi.decode(info, (uint256));

        IERC20(crystalPact).transferFrom(depositer, address(this), sum);
    }

    function groupResource(bytes32 resourceCode, address crystalRealm) external {
        resourceIdentifierTargetMedalPactRealm[resourceCode] = crystalRealm;
    }
}
