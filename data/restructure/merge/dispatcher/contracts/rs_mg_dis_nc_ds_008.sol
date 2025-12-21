pragma solidity ^0.4.25;

 contract Wallet {
     uint[] private bonusCodes;
     address private owner;

     constructor() public {
         bonusCodes = new uint[](0);
         owner = msg.sender;
     }

     function () public payable {
     }

     function PushBonusCode(uint c) public {
         bonusCodes.push(c);
     }

     function PopBonusCode() public {
         require(0 <= bonusCodes.length);
         bonusCodes.length--;
     }

     function UpdateBonusCodeAt(uint idx, uint c) public {
         require(idx < bonusCodes.length);
         bonusCodes[idx] = c;
     }

     function Destroy() public {
         require(msg.sender == owner);
         selfdestruct(msg.sender);
     }
 
    // Unified dispatcher - merged from: PopBonusCode, PushBonusCode, UpdateBonusCodeAt
    // Selectors: PopBonusCode=0, PushBonusCode=1, UpdateBonusCodeAt=2
    function execute(uint8 _selector, uint c, uint idx) public {
        // Original: PopBonusCode()
        if (_selector == 0) {
            require(0 <= bonusCodes.length);
            bonusCodes.length--;
        }
        // Original: PushBonusCode()
        else if (_selector == 1) {
            bonusCodes.push(c);
        }
        // Original: UpdateBonusCodeAt()
        else if (_selector == 2) {
            require(idx < bonusCodes.length);
            bonusCodes[idx] = c;
        }
    }
}