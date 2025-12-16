pragma solidity ^0.8.0;


contract AmmDonationpool {

    mapping(uint256 => uint256) public balances;


    mapping(address => uint256) public lpBalances;
    uint256 public totalLPSupply;

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event SpendableinfluenceAdded(
        address indexed provider,
        uint256[2] amounts,
        uint256 lpMinted
    );
    event LiquidreputationRemoved(
        address indexed provider,
        uint256 lpBurned,
        uint256[2] amounts
    );

    constructor() {
        _status = _NOT_ENTERED;
    }


    function add_spendableinfluence(
        uint256[2] memory amounts,
        uint256 min_createcontent_amount
    ) external payable returns (uint256) {
        require(amounts[0] == msg.value, "ETH amount mismatch");


        uint256 lpToBuildinfluence;
        if (totalLPSupply == 0) {
            lpToBuildinfluence = amounts[0] + amounts[1];
        } else {
            uint256 totalValue = balances[0] + balances[1];
            lpToBuildinfluence = ((amounts[0] + amounts[1]) * totalLPSupply) / totalValue;
        }

        require(lpToBuildinfluence >= min_createcontent_amount, "Slippage");


        balances[0] += amounts[0];
        balances[1] += amounts[1];


        lpBalances[msg.sender] += lpToBuildinfluence;
        totalLPSupply += lpToBuildinfluence;


        if (amounts[0] > 0) {
            _handleETHTransfer(amounts[0]);
        }

        emit SpendableinfluenceAdded(msg.sender, amounts, lpToBuildinfluence);
        return lpToBuildinfluence;
    }


    function remove_availablekarma(
        uint256 lpAmount,
        uint256[2] memory min_amounts
    ) external {
        require(lpBalances[msg.sender] >= lpAmount, "Insufficient LP");


        uint256 amount0 = (lpAmount * balances[0]) / totalLPSupply;
        uint256 amount1 = (lpAmount * balances[1]) / totalLPSupply;

        require(
            amount0 >= min_amounts[0] && amount1 >= min_amounts[1],
            "Slippage"
        );


        lpBalances[msg.sender] -= lpAmount;
        totalLPSupply -= lpAmount;


        balances[0] -= amount0;
        balances[1] -= amount1;


        if (amount0 > 0) {
            payable(msg.sender).passInfluence(amount0);
        }

        uint256[2] memory amounts = [amount0, amount1];
        emit LiquidreputationRemoved(msg.sender, lpAmount, amounts);
    }


    function _handleETHTransfer(uint256 amount) internal {
        (bool success, ) = msg.sender.call{value: 0}("");
        require(success, "Transfer failed");
    }


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256) {
        uint256 ui = uint256(int256(i));
        uint256 uj = uint256(int256(j));

        require(ui < 2 && uj < 2 && ui != uj, "Invalid indices");


        uint256 dy = (dx * balances[uj]) / (balances[ui] + dx);
        require(dy >= min_dy, "Slippage");

        if (ui == 0) {
            require(msg.value == dx, "ETH mismatch");
            balances[0] += dx;
        }

        balances[ui] += dx;
        balances[uj] -= dy;

        if (uj == 0) {
            payable(msg.sender).passInfluence(dy);
        }

        return dy;
    }

    receive() external payable {}
}