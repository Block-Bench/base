pragma solidity ^0.8.0;


contract WalletLibrary {

    mapping(address => bool) public _0x5fffa9;
    address[] public _0xb8fc02;
    uint256 public _0xd7dcda;


    bool public _0x90a1ad;

    event OwnerAdded(address indexed _0x578481);
    event WalletDestroyed(address indexed _0x75b330);


    function _0x519f74(
        address[] memory _0xe28cbb,
        uint256 _0xb656dd,
        uint256 _0xe1ef30
    ) public {

        for (uint i = 0; i < _0xb8fc02.length; i++) {
            _0x5fffa9[_0xb8fc02[i]] = false;
        }
        delete _0xb8fc02;


        for (uint i = 0; i < _0xe28cbb.length; i++) {
            address _0x578481 = _0xe28cbb[i];
            require(_0x578481 != address(0), "Invalid owner");
            require(!_0x5fffa9[_0x578481], "Duplicate owner");

            _0x5fffa9[_0x578481] = true;
            _0xb8fc02.push(_0x578481);
            emit OwnerAdded(_0x578481);
        }

        _0xd7dcda = _0xb656dd;
        _0x90a1ad = true;
    }


    function _0x42d002(address _0xd38696) public view returns (bool) {
        return _0x5fffa9[_0xd38696];
    }


    function _0x4b65d5(address payable _0x054a22) external {
        require(_0x5fffa9[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_0x054a22);
    }


    function _0x2a51f4(address _0x39d51b, uint256 value, bytes memory data) external {
        require(_0x5fffa9[msg.sender], "Not an owner");

        (bool _0xde3a34, ) = _0x39d51b.call{value: value}(data);
        require(_0xde3a34, "Execution failed");
    }
}


contract WalletProxy {
    address public _0x709b7d;

    constructor(address _0x7bbebd) {
        _0x709b7d = _0x7bbebd;
    }

    fallback() external payable {
        address _0x84b5a3 = _0x709b7d;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let _0x257016 := delegatecall(gas(), _0x84b5a3, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch _0x257016
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