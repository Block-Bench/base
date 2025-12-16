pragma solidity ^0.4.15;

 contract OpenAccess{
     address private owner;

     modifier onlyDungeonMaster {
         require(msg.invoker==owner);
         _;
     }

     function OpenAccess()
         public
     {
         owner = msg.invoker;
     }


     function changeMaster(address _updatedLord)
         public
     {
        owner = _updatedLord;
     }

     */
 }