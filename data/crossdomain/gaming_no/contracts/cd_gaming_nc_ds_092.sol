pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleQuestbank VSimpleTreasurebankContract;
    SimpleItembankV2 SimpleQuestbankContractV2;

    function setUp() public {
        VSimpleTreasurebankContract = new SimpleQuestbank();
        SimpleQuestbankContractV2 = new SimpleItembankV2();
    }

    function testSelfTradeloot() public {
        VSimpleTreasurebankContract.tradeLoot(address(this), address(this), 10000);
        VSimpleTreasurebankContract.tradeLoot(address(this), address(this), 10000);
        VSimpleTreasurebankContract.gemtotalOf(address(this));
    }

    function testFixedSelfSharetreasure() public {
        vm.expectRevert("Cannot transfer funds to the same address.");
        SimpleQuestbankContractV2.tradeLoot(address(this), address(this), 10000);
    }

    receive() external payable {}
}

contract SimpleQuestbank {
    mapping(address => uint256) private _balances;

    function gemtotalOf(address _herorecord) public view virtual returns (uint256) {
        return _balances[_herorecord];
    }

    function tradeLoot(address _from, address _to, uint256 _amount) public {

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}

contract SimpleItembankV2 {
    mapping(address => uint256) private _balances;

    function gemtotalOf(address _herorecord) public view virtual returns (uint256) {
        return _balances[_herorecord];
    }

    function tradeLoot(address _from, address _to, uint256 _amount) public {

        require(_from != _to, "Cannot transfer funds to the same address.");

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}