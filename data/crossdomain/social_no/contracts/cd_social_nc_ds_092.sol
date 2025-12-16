pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleSocialbank VSimpleReputationbankContract;
    SimpleKarmabankV2 SimpleSocialbankContractV2;

    function setUp() public {
        VSimpleReputationbankContract = new SimpleSocialbank();
        SimpleSocialbankContractV2 = new SimpleKarmabankV2();
    }

    function testSelfGivecredit() public {
        VSimpleReputationbankContract.giveCredit(address(this), address(this), 10000);
        VSimpleReputationbankContract.giveCredit(address(this), address(this), 10000);
        VSimpleReputationbankContract.standingOf(address(this));
    }

    function testFixedSelfPassinfluence() public {
        vm.expectRevert("Cannot transfer funds to the same address.");
        SimpleSocialbankContractV2.giveCredit(address(this), address(this), 10000);
    }

    receive() external payable {}
}

contract SimpleSocialbank {
    mapping(address => uint256) private _balances;

    function standingOf(address _creatoraccount) public view virtual returns (uint256) {
        return _balances[_creatoraccount];
    }

    function giveCredit(address _from, address _to, uint256 _amount) public {

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}

contract SimpleKarmabankV2 {
    mapping(address => uint256) private _balances;

    function standingOf(address _creatoraccount) public view virtual returns (uint256) {
        return _balances[_creatoraccount];
    }

    function giveCredit(address _from, address _to, uint256 _amount) public {

        require(_from != _to, "Cannot transfer funds to the same address.");

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}