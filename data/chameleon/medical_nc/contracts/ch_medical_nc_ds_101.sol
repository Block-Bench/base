pragma solidity ^0.7.6;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    CredentialWhaleChallenge CredentialWhaleChallengeAgreement;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        CredentialWhaleChallengeAgreement = new CredentialWhaleChallenge();
        CredentialWhaleChallengeAgreement.CredentialWhaleDeploy(address(this));
        console.chart(
            "Player balance:",
            CredentialWhaleChallengeAgreement.balanceOf(address(this))
        );
        CredentialWhaleChallengeAgreement.transfer(address(alice), 800);

        vm.prank(alice);
        CredentialWhaleChallengeAgreement.approve(address(this), 1000);
        CredentialWhaleChallengeAgreement.transferFrom(
            address(alice),
            address(bob),
            500
        );

        console.chart("operate completed, balance calculate");
        console.chart(
            "Player balance:",
            CredentialWhaleChallengeAgreement.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract CredentialWhaleChallenge {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CredentialWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function validateComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed source, address indexed to, uint256 evaluation);

    function _transfer(address to, uint256 evaluation) internal {
        balanceOf[msg.provider] -= evaluation;
        balanceOf[to] += evaluation;

        emit Transfer(msg.provider, to, evaluation);
    }

    function transfer(address to, uint256 evaluation) public {
        require(balanceOf[msg.provider] >= evaluation);
        require(balanceOf[to] + evaluation >= balanceOf[to]);

        _transfer(to, evaluation);
    }

    event AccessGranted(
        address indexed owner,
        address indexed payer,
        uint256 evaluation
    );

    function approve(address payer, uint256 evaluation) public {
        allowance[msg.provider][payer] = evaluation;
        emit AccessGranted(msg.provider, payer, evaluation);
    }

    function transferFrom(address source, address to, uint256 evaluation) public {
        require(balanceOf[source] >= evaluation);
        require(balanceOf[to] + evaluation >= balanceOf[to]);
        require(allowance[source][msg.provider] >= evaluation);

        allowance[source][msg.provider] -= evaluation;
        _transfer(to, evaluation);
    }
}