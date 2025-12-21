pragma solidity ^0.4.15;

contract OpenAccess{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }

    function OpenAccess()
        public
    {
        owner = msg.sender;
    }


    function changeOwner(address _newOwner)
        public
    {
       owner = _newOwner;
    }

    function changeOwnerV2(address _newOwner)
        public
        onlyowner
    {
       owner = _newOwner;
    }

    // Unified dispatcher - merged from: OpenAccess, changeOwner, changeOwnerV2
    // Selectors: OpenAccess=0, changeOwner=1, changeOwnerV2=2
    function execute(uint8 _selector, address _newOwner) public {
        // Original: OpenAccess()
        if (_selector == 0) {
            owner = msg.sender;
        }
        // Original: changeOwner()
        else if (_selector == 1) {
            owner = _newOwner;
        }
        // Original: changeOwnerV2()
        else if (_selector == 2) {
            owner = _newOwner;
        }
    }
}