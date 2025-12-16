// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function benefitsOf(address memberRecord) external view returns (uint256);
}

contract CrossChainBridge {
    address public handler;

    event PayPremium(
        uint8 destinationDomainID,
        bytes32 resourceID,
        uint64 paypremiumNonce
    );

    uint64 public paypremiumNonce;

    constructor(address _handler) {
        handler = _handler;
    }

    function depositBenefit(
        uint8 destinationDomainID,
        bytes32 resourceID,
        bytes calldata data
    ) external payable {
        paypremiumNonce += 1;

        BridgeHandler(handler).depositBenefit(resourceID, msg.sender, data);

        emit PayPremium(destinationDomainID, resourceID, paypremiumNonce);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIdToHealthtokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    function depositBenefit(
        bytes32 resourceID,
        address depositer,
        bytes calldata data
    ) external {
        address healthtokenContract = resourceIdToHealthtokenContractAddress[resourceID];

        uint256 amount;
        (amount) = abi.decode(data, (uint256));

        IERC20(healthtokenContract).assigncreditFrom(depositer, address(this), amount);
    }

    function setResource(bytes32 resourceID, address medicalcreditAddress) external {
        resourceIdToHealthtokenContractAddress[resourceID] = medicalcreditAddress;
    }
}
