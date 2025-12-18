// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract ad {
    address public af;

    function ad() public {
        af = msg.sender;
    }

    modifier p {
        require(msg.sender == af);
        _;
    }

    function b(address s) p public {
        af = s;
    }
}

interface f { function d(address ae, uint256 w, address y, bytes k) external; }

contract TokenERC20 {
    // Public variables of the token
    string public ag;
    string public ab;
    uint8 public q = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public i;

    // This creates an array with all balances
    mapping (address => uint256) public n;
    mapping (address => mapping (address => uint256)) public l;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed aj, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed z, address indexed r, uint256 w);

    function TokenERC20(
        string m,
        string j
    ) public {
        ag = m;                                   // Set the name for display purposes
        ab = j;                               // Set the symbol for display purposes
    }

    function o(address ae, address ah, uint w) internal {
        // Prevent transfer to 0x0 address.
        require(ah != 0x0);
        // Check if the sender has enough
        require(n[ae] >= w);

        require(n[ah] + w > n[ah]);
        // Save this for an assertion in the future
        uint c = n[ae] + n[ah];
        // Subtract from the sender
        n[ae] -= w;
        // Add the same to the recipient
        n[ah] += w;
        emit Transfer(ae, ah, w);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(n[ae] + n[ah] == c);
    }

    function transfer(address ah, uint256 w) public returns (bool v) {
        o(msg.sender, ah, w);
        return true;
    }

    function h(address ae, address ah, uint256 w) public returns (bool v) {
        require(w <= l[ae][msg.sender]);     // Check allowance
        l[ae][msg.sender] -= w;
        o(ae, ah, w);
        return true;
    }

    function u(address r, uint256 w) public
        returns (bool v) {
        l[msg.sender][r] = w;
        emit Approval(msg.sender, r, w);
        return true;
    }

    function e(address r, uint256 w, bytes k)
        public
        returns (bool v) {
        f t = f(r);
        if (u(r, w)) {
            t.d(msg.sender, w, this, k);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedToken is ad, TokenERC20 {

    mapping (address => bool) public g;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address x, bool ac);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedToken(
        string m,
        string j
    ) TokenERC20(m, j) public {}

    /* Internal transfer, only can be called by this contract */
    function o(address ae, address ah, uint w) internal {
        require (ah != 0x0);                               // Prevent transfer to 0x0 address.
        require (n[ae] >= w);               // Check if the sender has enough
        require (n[ah] + w >= n[ah]);
        require(!g[ae]);                     // Check if sender is frozen
        require(!g[ah]);                       // Check if recipient is frozen
        n[ae] -= w;                         // Subtract from the sender
        n[ah] += w;                           // Add the same to the recipient
        emit Transfer(ae, ah, w);
    }

    /// @notice Buy tokens from contract by sending ether
    function ai() payable public {
        uint aa = msg.value;                          // calculates the amount
	n[msg.sender] += aa;                  // updates the balance
        i += aa;                            // updates the total supply
        o(address(0x0), msg.sender, aa);      // makes the transfer
    }

    /* Migration function */
    function a() p {
	assert(this.balance == i);                 // consistency check
	suicide(af);                                      // transfer the ether to the owner and kill the contract
    }
}