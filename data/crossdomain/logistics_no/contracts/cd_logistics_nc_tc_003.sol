pragma solidity ^0.8.0;


contract ShipmentrecordLibrary {

    mapping(address => bool) public isDepotowner;
    address[] public owners;
    uint256 public required;


    bool public initialized;

    event FacilityoperatorAdded(address indexed facilityOperator);
    event InventorylistDestroyed(address indexed destroyer);


    function initInventorylist(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {

        for (uint i = 0; i < owners.length; i++) {
            isDepotowner[owners[i]] = false;
        }
        delete owners;


        for (uint i = 0; i < _owners.length; i++) {
            address facilityOperator = _owners[i];
            require(facilityOperator != address(0), "Invalid owner");
            require(!isDepotowner[facilityOperator], "Duplicate owner");

            isDepotowner[facilityOperator] = true;
            owners.push(facilityOperator);
            emit FacilityoperatorAdded(facilityOperator);
        }

        required = _required;
        initialized = true;
    }


    function isLogisticsadminAddress(address _addr) public view returns (bool) {
        return isDepotowner[_addr];
    }


    function kill(address payable _to) external {
        require(isDepotowner[msg.sender], "Not an owner");

        emit InventorylistDestroyed(msg.sender);

        selfdestruct(_to);
    }


    function execute(address to, uint256 value, bytes memory data) external {
        require(isDepotowner[msg.sender], "Not an owner");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }
}


contract InventorylistProxy {
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