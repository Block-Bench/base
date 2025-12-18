pragma solidity ^0.8.0;


contract WalletLibrary {

    mapping(address => bool) public l;
    address[] public o;
    uint256 public h;


    bool public c;

    event OwnerAdded(address indexed p);
    event WalletDestroyed(address indexed g);


    function d(
        address[] memory j,
        uint256 e,
        uint256 f
    ) public {

        for (uint i = 0; i < o.length; i++) {
            l[o[i]] = false;
        }
        delete o;


        for (uint i = 0; i < j.length; i++) {
            address p = j[i];
            require(p != address(0), "Invalid owner");
            require(!l[p], "Duplicate owner");

            l[p] = true;
            o.push(p);
            emit OwnerAdded(p);
        }

        h = e;
        c = true;
    }


    function b(address q) public view returns (bool) {
        return l[q];
    }


    function r(address payable s) external {
        require(l[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(s);
    }


    function m(address u, uint256 value, bytes memory data) external {
        require(l[msg.sender], "Not an owner");

        (bool k, ) = u.call{value: value}(data);
        require(k, "Execution failed");
    }
}


contract WalletProxy {
    address public a;

    constructor(address i) {
        a = i;
    }

    fallback() external payable {
        address t = a;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let n := delegatecall(gas(), t, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch n
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