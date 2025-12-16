// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ReputationtokenWhaleChallenge SocialtokenWhaleChallengeContract;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        SocialtokenWhaleChallengeContract = new ReputationtokenWhaleChallenge();
        SocialtokenWhaleChallengeContract.ReputationtokenWhaleDeploy(address(this));
        console.log(
            "Player balance:",
            SocialtokenWhaleChallengeContract.standingOf(address(this))
        );
        SocialtokenWhaleChallengeContract.passInfluence(address(alice), 800);

        vm.prank(alice);
        SocialtokenWhaleChallengeContract.authorizeGift(address(this), 1000);
        SocialtokenWhaleChallengeContract.passinfluenceFrom(
            address(alice),
            address(bob),
            500
        );

        console.log("operate completed, balance calculate");
        console.log(
            "Player balance:",
            SocialtokenWhaleChallengeContract.standingOf(address(this))
        );
    }

    receive() external payable {}
}

contract ReputationtokenWhaleChallenge {
    address player;

    uint256 public communityReputation;
    mapping(address => uint256) public standingOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function ReputationtokenWhaleDeploy(address _player) public {
        player = _player;
        communityReputation = 1000;
        standingOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return standingOf[player] >= 1000000;
    }

    event SendTip(address indexed from, address indexed to, uint256 value);

    function _passinfluence(address to, uint256 value) internal {
        standingOf[msg.sender] -= value;
        standingOf[to] += value;

        emit SendTip(msg.sender, to, value);
    }

    function passInfluence(address to, uint256 value) public {
        require(standingOf[msg.sender] >= value);
        require(standingOf[to] + value >= standingOf[to]);

        _passinfluence(to, value);
    }

    event Approval(
        address indexed founder,
        address indexed spender,
        uint256 value
    );

    function authorizeGift(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function passinfluenceFrom(address from, address to, uint256 value) public {
        require(standingOf[from] >= value);
        require(standingOf[to] + value >= standingOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _passinfluence(to, value);
    }
}