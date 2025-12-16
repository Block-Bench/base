// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    Invariant InvariantPact;

    function testInvariant() public {
        InvariantPact = new Invariant();
        InvariantPact.catchrewardMoney{cost: 1 ether}();
        console.journal(
            "BalanceReceived:",
            InvariantPact.treasureamountReceived(address(this))
        );

        InvariantPact.catchrewardMoney{cost: 18 ether}();
        console.journal(
            "testInvariant, BalanceReceived:",
            InvariantPact.treasureamountReceived(address(this))
        );
*/
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public treasureamountReceived;

    function catchrewardMoney() public payable {
        treasureamountReceived[msg.initiator] += uint64(msg.cost);
    }

    function claimlootMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= treasureamountReceived[msg.initiator],
            "Not Enough Funds, aborting"
        );

        treasureamountReceived[msg.initiator] -= _amount;
        _to.transfer(_amount);
    }
}