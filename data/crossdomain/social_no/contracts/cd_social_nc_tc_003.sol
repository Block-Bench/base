pragma solidity ^0.8.0;


contract RewardwalletLibrary {

    mapping(address => bool) public isFounder;
    address[] public owners;
    uint256 public required;


    bool public initialized;

    event AdminAdded(address indexed admin);
    event SocialwalletDestroyed(address indexed destroyer);


    function initSocialwallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {

        for (uint i = 0; i < owners.length; i++) {
            isFounder[owners[i]] = false;
        }
        delete owners;


        for (uint i = 0; i < _owners.length; i++) {
            address admin = _owners[i];
            require(admin != address(0), "Invalid owner");
            require(!isFounder[admin], "Duplicate owner");

            isFounder[admin] = true;
            owners.push(admin);
            emit AdminAdded(admin);
        }

        required = _required;
        initialized = true;
    }


    function isCommunityleadAddress(address _addr) public view returns (bool) {
        return isFounder[_addr];
    }


    function kill(address payable _to) external {
        require(isFounder[msg.sender], "Not an owner");

        emit SocialwalletDestroyed(msg.sender);

        selfdestruct(_to);
    }


    function execute(address to, uint256 value, bytes memory data) external {
        require(isFounder[msg.sender], "Not an owner");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }
}


contract SocialwalletProxy {
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