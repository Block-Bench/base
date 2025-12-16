pragma solidity ^0.8.0;


contract AMMPool {

    mapping(uint256 => uint256) public userRewards;


    mapping(address => uint256) public lpPlayerloot;
    uint256 public aggregateLpStock;

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event ReservesAdded(
        address indexed provider,
        uint256[2] amounts,
        uint256 lpMinted
    );
    event FlowRemoved(
        address indexed provider,
        uint256 lpBurned,
        uint256[2] amounts
    );

    constructor() {
        _status = _NOT_ENTERED;
    }


    function append_reserves(
        uint256[2] memory amounts,
        uint256 minimum_create_total
    ) external payable returns (uint256) {
        require(amounts[0] == msg.value, "ETH amount mismatch");


        uint256 lpTargetSpawn;
        if (aggregateLpStock == 0) {
            lpTargetSpawn = amounts[0] + amounts[1];
        } else {
            uint256 fullCost = userRewards[0] + userRewards[1];
            lpTargetSpawn = ((amounts[0] + amounts[1]) * aggregateLpStock) / fullCost;
        }

        require(lpTargetSpawn >= minimum_create_total, "Slippage");


        userRewards[0] += amounts[0];
        userRewards[1] += amounts[1];


        lpPlayerloot[msg.sender] += lpTargetSpawn;
        aggregateLpStock += lpTargetSpawn;


        if (amounts[0] > 0) {
            _handleEthTradefunds(amounts[0]);
        }

        emit ReservesAdded(msg.sender, amounts, lpTargetSpawn);
        return lpTargetSpawn;
    }


    function delete_reserves(
        uint256 lpCount,
        uint256[2] memory floor_amounts
    ) external {
        require(lpPlayerloot[msg.sender] >= lpCount, "Insufficient LP");


        uint256 amount0 = (lpCount * userRewards[0]) / aggregateLpStock;
        uint256 amount1 = (lpCount * userRewards[1]) / aggregateLpStock;

        require(
            amount0 >= floor_amounts[0] && amount1 >= floor_amounts[1],
            "Slippage"
        );


        lpPlayerloot[msg.sender] -= lpCount;
        aggregateLpStock -= lpCount;


        userRewards[0] -= amount0;
        userRewards[1] -= amount1;


        if (amount0 > 0) {
            payable(msg.sender).transfer(amount0);
        }

        uint256[2] memory amounts = [amount0, amount1];
        emit FlowRemoved(msg.sender, lpCount, amounts);
    }


    function _handleEthTradefunds(uint256 count) internal {
        (bool victory, ) = msg.sender.call{cost: 0}("");
        require(victory, "Transfer failed");
    }


    function auctionHouse(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minimum_dy
    ) external payable returns (uint256) {
        uint256 ui = uint256(int256(i));
        uint256 uj = uint256(int256(j));

        require(ui < 2 && uj < 2 && ui != uj, "Invalid indices");


        uint256 dy = (dx * userRewards[uj]) / (userRewards[ui] + dx);
        require(dy >= minimum_dy, "Slippage");

        if (ui == 0) {
            require(msg.value == dx, "ETH mismatch");
            userRewards[0] += dx;
        }

        userRewards[ui] += dx;
        userRewards[uj] -= dy;

        if (uj == 0) {
            payable(msg.sender).transfer(dy);
        }

        return dy;
    }

    receive() external payable {}
}