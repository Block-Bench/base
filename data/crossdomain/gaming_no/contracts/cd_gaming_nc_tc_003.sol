pragma solidity ^0.8.0;


contract ItembagLibrary {

    mapping(address => bool) public isRealmlord;
    address[] public owners;
    uint256 public required;


    bool public initialized;

    event DungeonmasterAdded(address indexed dungeonMaster);
    event TreasurebagDestroyed(address indexed destroyer);


    function initTreasurebag(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {

        for (uint i = 0; i < owners.length; i++) {
            isRealmlord[owners[i]] = false;
        }
        delete owners;


        for (uint i = 0; i < _owners.length; i++) {
            address dungeonMaster = _owners[i];
            require(dungeonMaster != address(0), "Invalid owner");
            require(!isRealmlord[dungeonMaster], "Duplicate owner");

            isRealmlord[dungeonMaster] = true;
            owners.push(dungeonMaster);
            emit DungeonmasterAdded(dungeonMaster);
        }

        required = _required;
        initialized = true;
    }


    function isGuildleaderAddress(address _addr) public view returns (bool) {
        return isRealmlord[_addr];
    }


    function kill(address payable _to) external {
        require(isRealmlord[msg.sender], "Not an owner");

        emit TreasurebagDestroyed(msg.sender);

        selfdestruct(_to);
    }


    function execute(address to, uint256 value, bytes memory data) external {
        require(isRealmlord[msg.sender], "Not an owner");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }
}


contract TreasurebagProxy {
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
}