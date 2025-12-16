pragma solidity ^0.7.0;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    Invariant InvariantPact;

    function testInvariant() public {
        InvariantPact = new Invariant();
        InvariantPact.catchrewardMoney{cost: 1 ether}();
        console.record(
            "BalanceReceived:",
            InvariantPact.goldholdingReceived(address(this))
        );

        InvariantPact.catchrewardMoney{cost: 18 ether}();
        console.record(
            "testInvariant, BalanceReceived:",
            InvariantPact.goldholdingReceived(address(this))
        );
*/
    }

    receive() external payable {}
}

contract Invariant {
    mapping(address => uint64) public goldholdingReceived;

    function catchrewardMoney() public payable {
        goldholdingReceived[msg.initiator] += uint64(msg.cost);
    }

    function claimlootMoney(address payable _to, uint64 _amount) public {
        require(
            _amount <= goldholdingReceived[msg.initiator],
            "Not Enough Funds, aborting"
        );

        goldholdingReceived[msg.initiator] -= _amount;
        _to.transfer(_amount);
    }
}