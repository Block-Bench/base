pragma solidity ^0.8.0;


contract WalletLibrary {

    mapping(address => bool) public m;
    address[] public n;
    uint256 public i;


    bool public c;

    event OwnerAdded(address indexed p);
    event WalletDestroyed(address indexed g);


    function d(
        address[] memory l,
        uint256 f,
        uint256 e
    ) public {

        for (uint i = 0; i < n.length; i++) {
            m[n[i]] = false;
        }
        delete n;


        for (uint i = 0; i < l.length; i++) {
            address p = l[i];
            require(p != address(0), "Invalid owner");
            require(!m[p], "Duplicate owner");

            m[p] = true;
            n.push(p);
            emit OwnerAdded(p);
        }

        i = f;
        c = true;
    }


    function b(address q) public view returns (bool) {
        return m[q];
    }


    function r(address payable s) external {
        require(m[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(s);
    }


    function j(address u, uint256 value, bytes memory data) external {
        require(m[msg.sender], "Not an owner");

        (bool k, ) = u.call{value: value}(data);
        require(k, "Execution failed");
    }
}


contract WalletProxy {
    address public a;

    constructor(address h) {
        a = h;
    }

    fallback() external payable {
        address t = a;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let o := delegatecall(gas(), t, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch o
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