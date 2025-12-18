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

 
    // Unified dispatcher - merged from: changeOwner, OpenAccess
    // Selectors: changeOwner=0, OpenAccess=1
    function execute(uint8 _selector, address _newOwner) public {
        // Original: changeOwner()
        if (_selector == 0) {
            owner = _newOwner;
        }
        // Original: OpenAccess()
        else if (_selector == 1) {
            owner = msg.sender;
        }
    }
}