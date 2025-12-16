pragma solidity ^0.8.0;

interface IERC20 {

    function transferFrom(
    address from,
    address to,
    uint256 amount
) external returns (bool);

function balanceOf(address account) external view returns (uint256);
}

contract CrossChainBridge {
    address public handler;

    event Deposit(
    uint8 destinationDomainID,
    bytes32 resourceID,
    uint64 depositNonce
);

uint64 public depositNonce;

constructor(address _handler) {
    handler = _handler;
}

function deposit(
uint8 destinationDomainID,
bytes32 resourceID,
bytes calldata data
) external payable {
    depositNonce += 1;

    BridgeHandler(handler).deposit(resourceID, msg.sender, data);

    emit Deposit(destinationDomainID, resourceID, depositNonce);
}
}

contract BridgeHandler {
    mapping(bytes32 => address) public resourceIDToTokenContractAddress;
    mapping(address => bool) public contractWhitelist;

    function deposit(
    bytes32 resourceID,
    address depositer,
    bytes calldata data
) external {
    address tokenContract = resourceIDToTokenContractAddress[resourceID];

    uint256 amount;
    (amount) = abi.decode(data, (uint256));

    IERC20(tokenContract).transferFrom(depositer, address(this), amount);
}

function setResource(bytes32 resourceID, address tokenAddress) external {
    resourceIDToTokenContractAddress[resourceID] = tokenAddress;
}
}