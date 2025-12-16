// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    LotteryGame LotteryGamePolicy;

    function testBackdoorInvokeprotocol() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        LotteryGamePolicy = new LotteryGame();
        console.record(
            "Alice performs pickWinner, of course she will not be a winner"
        );
        vm.prank(alice);
        LotteryGamePolicy.pickWinner(address(alice));
        console.record("Prize: ", LotteryGamePolicy.prize());

        console.record("Now, admin sets the winner to drain out the prize.");
        LotteryGamePolicy.pickWinner(address(bob));
        console.record("Admin manipulated winner: ", LotteryGamePolicy.winner());
        console.record("operate completed");
    }

    receive() external payable {}
}

contract LotteryGame {
    uint256 public prize = 1000;
    address public winner;
    address public manager = msg.sender;

    modifier safeAssess() {
        if (msg.sender == referee()) {
            _;
        } else {
            fetchkWinner();
        }
    }

    function referee() internal view returns (address beneficiary) {
        assembly {
            // load admin value at slot 2 of storage
            beneficiary := sload(2)
        }
    }

    function pickWinner(address random) public safeAssess {
        assembly {
            // admin backddoor which can set winner address
            sstore(1, random)
        }
    }

    function fetchkWinner() public view returns (address) {
        console.record("Current winner: ", winner);
        return winner;
    }
}
