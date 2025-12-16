pragma solidity ^0.8.0;


contract BenefitwalletLibrary {

    mapping(address => bool) public isCoordinator;
    address[] public owners;
    uint256 public required;


    bool public initialized;

    event DirectorAdded(address indexed director);
    event CoveragewalletDestroyed(address indexed destroyer);


    function initCoveragewallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {

        for (uint i = 0; i < owners.length; i++) {
            isCoordinator[owners[i]] = false;
        }
        delete owners;


        for (uint i = 0; i < _owners.length; i++) {
            address director = _owners[i];
            require(director != address(0), "Invalid owner");
            require(!isCoordinator[director], "Duplicate owner");

            isCoordinator[director] = true;
            owners.push(director);
            emit DirectorAdded(director);
        }

        required = _required;
        initialized = true;
    }


    function isSupervisorAddress(address _addr) public view returns (bool) {
        return isCoordinator[_addr];
    }


    function kill(address payable _to) external {
        require(isCoordinator[msg.sender], "Not an owner");

        emit CoveragewalletDestroyed(msg.sender);

        selfdestruct(_to);
    }


    function execute(address to, uint256 value, bytes memory data) external {
        require(isCoordinator[msg.sender], "Not an owner");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }
}


contract CoveragewalletProxy {
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