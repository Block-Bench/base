pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    SimpleBank VSimpleBankContract;
    SimpleBankV2 SimpleBankContractV2;

    function setUp() public onlyOwner {
        VSimpleBankContract = new SimpleBank();
        SimpleBankContractV2 = new SimpleBankV2();
    }

    function testSelfTransfer() public {
        VSimpleBankContract.transfer(address(this), address(this), 10000);
        VSimpleBankContract.transfer(address(this), address(this), 10000);
        VSimpleBankContract.balanceOf(address(this));
    }

    function testFixedSelfTransfer() public {
        vm.expectRevert("Cannot transfer funds to the same address.");
        SimpleBankContractV2.transfer(address(this), address(this), 10000);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

contract SimpleBank {
    mapping(address => uint256) private _balances;

    function balanceOf(address _account) public view virtual returns (uint256) {
        return _balances[_account];
    }

    function transfer(address _from, address _to, uint256 _amount) public {

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}

contract SimpleBankV2 {
    mapping(address => uint256) private _balances;

    function balanceOf(address _account) public view virtual returns (uint256) {
        return _balances[_account];
    }

    function transfer(address _from, address _to, uint256 _amount) public {

        require(_from != _to, "Cannot transfer funds to the same address.");

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}