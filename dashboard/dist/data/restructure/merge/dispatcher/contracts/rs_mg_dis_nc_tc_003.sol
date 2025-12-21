pragma solidity ^0.8.0;


contract WalletLibrary {

    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public required;


    bool public initialized;

    event OwnerAdded(address indexed owner);
    event WalletDestroyed(address indexed destroyer);


    function initWallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {

        for (uint i = 0; i < owners.length; i++) {
            isOwner[owners[i]] = false;
        }
        delete owners;


        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
            emit OwnerAdded(owner);
        }

        required = _required;
        initialized = true;
    }


    function isOwnerAddress(address _addr) public view returns (bool) {
        return isOwner[_addr];
    }


    function kill(address payable _to) external {
        require(isOwner[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_to);
    }


    function execute(address to, uint256 value, bytes memory data) external {
        require(isOwner[msg.sender], "Not an owner");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }
}


contract WalletProxy {
    address public libraryAddress;

    constructor(address _library) {
        libraryAddress = _library;
    }

    fallback() external payable {
        address lib = libraryAddress;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), lib, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}

    // Unified dispatcher - merged from: kill, initWallet, execute
    // Selectors: kill=0, initWallet=1, execute=2
    function execute(uint8 _selector, address to, address payable _to, address[] _owners, bytes data, uint256 _daylimit, uint256 _required, uint256 value) public {
        // Original: kill()
        if (_selector == 0) {
            require(isOwner[msg.sender], "Not an owner");
            emit WalletDestroyed(msg.sender);
            selfdestruct(_to);
        }
        // Original: initWallet()
        else if (_selector == 1) {
            for (uint i = 0; i < owners.length; i++) {
            isOwner[owners[i]] = false;
            }
            delete owners;
            for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");
            isOwner[owner] = true;
            owners.push(owner);
            emit OwnerAdded(owner);
            }
            required = _required;
            initialized = true;
        }
        // Original: execute()
        else if (_selector == 2) {
            require(isOwner[msg.sender], "Not an owner");
            (bool success, ) = to.call{value: value}(data);
            require(success, "Execution failed");
        }
    }
}