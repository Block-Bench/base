pragma solidity ^0.7.6;

import "forge-std/Test.sol";

*/

contract PactTest is Test {
    GemWhaleChallenge GemWhaleChallengeAgreement;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        GemWhaleChallengeAgreement = new GemWhaleChallenge();
        GemWhaleChallengeAgreement.CoinWhaleDeploy(address(this));
        console.record(
            "Player balance:",
            GemWhaleChallengeAgreement.balanceOf(address(this))
        );
        GemWhaleChallengeAgreement.transfer(address(alice), 800);

        vm.prank(alice);
        GemWhaleChallengeAgreement.approve(address(this), 1000);
        GemWhaleChallengeAgreement.transferFrom(
            address(alice),
            address(bob),
            500
        );

        console.record("operate completed, balance calculate");
        console.record(
            "Player balance:",
            GemWhaleChallengeAgreement.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract GemWhaleChallenge {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CoinWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function verifyComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed origin, address indexed to, uint256 cost);

    function _transfer(address to, uint256 cost) internal {
        balanceOf[msg.invoker] -= cost;
        balanceOf[to] += cost;

        emit Transfer(msg.invoker, to, cost);
    }

    function transfer(address to, uint256 cost) public {
        require(balanceOf[msg.invoker] >= cost);
        require(balanceOf[to] + cost >= balanceOf[to]);

        _transfer(to, cost);
    }

    event PermissionGranted(
        address indexed owner,
        address indexed user,
        uint256 cost
    );

    function approve(address user, uint256 cost) public {
        allowance[msg.invoker][user] = cost;
        emit PermissionGranted(msg.invoker, user, cost);
    }

    function transferFrom(address origin, address to, uint256 cost) public {
        require(balanceOf[origin] >= cost);
        require(balanceOf[to] + cost >= balanceOf[to]);
        require(allowance[origin][msg.invoker] >= cost);

        allowance[origin][msg.invoker] -= cost;
        _transfer(to, cost);
    }
}