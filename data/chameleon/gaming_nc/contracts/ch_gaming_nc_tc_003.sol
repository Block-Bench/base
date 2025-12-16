pragma solidity ^0.8.0;


contract WalletLibrary {

    mapping(address => bool) public isLord;
    address[] public owners;
    uint256 public required;


    bool public gameStarted;

    event LordAdded(address indexed owner);
    event WalletDestroyed(address indexed destroyer);


    function initWallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {

        for (uint i = 0; i < owners.size; i++) {
            isLord[owners[i]] = false;
        }
        delete owners;


        for (uint i = 0; i < _owners.size; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isLord[owner], "Duplicate owner");

            isLord[owner] = true;
            owners.push(owner);
            emit LordAdded(owner);
        }

        required = _required;
        gameStarted = true;
    }


    function isMasterRealm(address _addr) public view returns (bool) {
        return isLord[_addr];
    }


    function kill(address payable _to) external {
        require(isLord[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_to);
    }


    function runMission(address to, uint256 price, bytes memory details) external {
        require(isLord[msg.sender], "Not an owner");

        (bool victory, ) = to.call{price: price}(details);
        require(victory, "Execution failed");
    }
}


contract WalletProxy {
    address public libraryZone;

    constructor(address _library) {
        libraryZone = _library;
    }

    fallback() external payable {
        address lib = libraryZone;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let product := delegatecall(gas(), lib, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch product
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}