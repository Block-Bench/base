pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract LoanToken {
    string public name = "iETH";
    string public symbol = "iETH";

    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    uint256 public totalAssetBorrow;
    uint256 public totalAssetSupply;

    function mintWithEther(
        address receiver
    ) external payable returns (uint256 mintAmount) {
        uint256 currentPrice = _tokenPrice();
        mintAmount = (msg.value * 1e18) / currentPrice;

        balances[receiver] += mintAmount;
        totalSupply += mintAmount;
        totalAssetSupply += msg.value;

        return mintAmount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        _notifyTransfer(msg.sender, to, amount);

        return true;
    }

    function _notifyTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (_isContract(to)) {
            (bool success, ) = to.call("");
            success;
        }
    }

    function burnToEther(
        address receiver,
        uint256 amount
    ) external returns (uint256 ethAmount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 currentPrice = _tokenPrice();
        ethAmount = (amount * currentPrice) / 1e18;

        balances[msg.sender] -= amount;
        totalSupply -= amount;
        totalAssetSupply -= ethAmount;

        payable(receiver).transfer(ethAmount);

        return ethAmount;
    }

    function _tokenPrice() internal view returns (uint256) {
        if (totalSupply == 0) {
            return 1e18;
        }
        return (totalAssetSupply * 1e18) / totalSupply;
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    receive() external payable {}

    // Unified dispatcher - merged from: transfer, mintWithEther, burnToEther
    // Selectors: transfer=0, mintWithEther=1, burnToEther=2
    function execute(uint8 _selector, address receiver, address to, uint256 amount) public payable {
        // Original: transfer()
        if (_selector == 0) {
            require(balances[msg.sender] >= amount, "Insufficient balance");
            balances[msg.sender] -= amount;
            balances[to] += amount;
            _notifyTransfer(msg.sender, to, amount);
            return true;
        }
        // Original: mintWithEther()
        else if (_selector == 1) {
            uint256 currentPrice = _tokenPrice();
            mintAmount = (msg.value * 1e18) / currentPrice;
            balances[receiver] += mintAmount;
            totalSupply += mintAmount;
            totalAssetSupply += msg.value;
            return mintAmount;
        }
        // Original: burnToEther()
        else if (_selector == 2) {
            require(balances[msg.sender] >= amount, "Insufficient balance");
            uint256 currentPrice = _tokenPrice();
            ethAmount = (amount * currentPrice) / 1e18;
            balances[msg.sender] -= amount;
            totalSupply -= amount;
            totalAssetSupply -= ethAmount;
            payable(receiver).transfer(ethAmount);
            return ethAmount;
        }
    }
}