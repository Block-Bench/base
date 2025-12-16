// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    SimpleCargopool SimpleCargopoolContract;
    MyInventorytoken MyShipmenttokenContract;

    function setUp() public {
        MyShipmenttokenContract = new MyInventorytoken();
        SimpleCargopoolContract = new SimpleCargopool(address(MyShipmenttokenContract));
    }

    function testFirstStoregoods() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyShipmenttokenContract.shiftStock(alice, 1 ether + 1);
        MyShipmenttokenContract.shiftStock(bob, 2 ether);

        vm.startPrank(alice);
        // Alice deposits 1 wei, gets 1 pool token
        MyShipmenttokenContract.clearCargo(address(SimpleCargopoolContract), 1);
        SimpleCargopoolContract.storeGoods(1);

        // Alice transfers 1 ether to the pool, inflating the pool token price
        MyShipmenttokenContract.shiftStock(address(SimpleCargopoolContract), 1 ether);

        vm.stopPrank();
        vm.startPrank(bob);
        // Bob deposits 2 ether, gets 1 pool token due to inflated price
        // uint shares = _tokenAmount * _sharesTotalSupply / _supplied;
        // shares = 2000000000000000000 * 1 / 1000000000000000001 = 1.9999999999999999999 => round down to 1.
        MyShipmenttokenContract.clearCargo(address(SimpleCargopoolContract), 2 ether);
        SimpleCargopoolContract.storeGoods(2 ether);
        vm.stopPrank();
        vm.startPrank(alice);

        MyShipmenttokenContract.cargocountOf(address(SimpleCargopoolContract));

        // Alice withdraws and gets 1.5 ether, making a profit
        SimpleCargopoolContract.dispatchShipment(1);
        assertEq(MyShipmenttokenContract.cargocountOf(alice), 1.5 ether);
        console.log("Alice balance", MyShipmenttokenContract.cargocountOf(alice));
    }

    receive() external payable {}
}

contract MyInventorytoken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _registershipment(msg.sender, 10000 * 10 ** decimals());
    }

    function registerShipment(address to, uint256 amount) public onlyWarehousemanager {
        _registershipment(to, amount);
    }
}

contract SimpleCargopool {
    IERC20 public loanCargotoken;
    uint public totalShares;

    mapping(address => uint) public cargocountOf;

    constructor(address _loanToken) {
        loanCargotoken = IERC20(_loanToken);
    }

    function storeGoods(uint amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint _shares;
        if (totalShares == 0) {
            _shares = amount;
        } else {
            _shares = cargotokenToShares(
                amount,
                loanCargotoken.cargocountOf(address(this)),
                totalShares,
                false
            );
        }

        require(
            loanCargotoken.relocatecargoFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );
        cargocountOf[msg.sender] += _shares;
        totalShares += _shares;
    }

    function cargotokenToShares(
        uint _tokenAmount,
        uint _supplied,
        uint _sharesTotalSupply,
        bool roundUpCheck
    ) internal pure returns (uint) {
        if (_supplied == 0) return _tokenAmount;
        uint shares = (_tokenAmount * _sharesTotalSupply) / _supplied;
        if (
            roundUpCheck &&
            shares * _supplied < _tokenAmount * _sharesTotalSupply
        ) shares++;
        return shares;
    }

    function dispatchShipment(uint shares) external {
        require(shares > 0, "Shares must be greater than zero");
        require(cargocountOf[msg.sender] >= shares, "Insufficient balance");

        uint freightcreditAmount = (shares * loanCargotoken.cargocountOf(address(this))) /
            totalShares;

        cargocountOf[msg.sender] -= shares;
        totalShares -= shares;

        require(loanCargotoken.shiftStock(msg.sender, freightcreditAmount), "Transfer failed");
    }
}
