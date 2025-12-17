// https://etherscan.io/address/0xf91546835f756da0c10cfa0cda95b15577b84aa7#code

pragma solidity ^0.4.23;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
contract Token {
    /// total amount of tokens
    uint256 public _0x0a751e;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x314878(address _0x0e1c1f) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0x5a8149, uint256 _0x39800b) public returns (bool _0x91ebf6);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function _0x9d7a57(address _0xe9aabe, address _0x5a8149, uint256 _0x39800b) public returns (bool _0x91ebf6);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0xd2a040(address _0xc63f9e, uint256 _0x39800b) public returns (bool _0x91ebf6);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function _0xdd0260(address _0x0e1c1f, address _0xc63f9e) public constant returns (uint256 _0x614721);

    event Transfer(address indexed _0xe9aabe, address indexed _0x5a8149, uint256 _0x39800b);
    event Approval(address indexed _0x0e1c1f, address indexed _0xc63f9e, uint256 _0x39800b);
}

library ECTools {

    // @dev Recovers the address which has signed a message
    // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
    function _0xa89ddd(bytes32 _0x810b17, string _0x6397fe) public pure returns (address) {
        require(_0x810b17 != 0x00);

        // need this for test RPC
        bytes memory _0x6fad22 = "\x19Ethereum Signed Message:\n32";
        bytes32 _0xb6d941 = _0x468a1a(abi._0xfb4673(_0x6fad22, _0x810b17));

        if (bytes(_0x6397fe).length != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = _0x648fe4(_0x38d2e5(_0x6397fe, 2, 132));
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v < 27 || v > 28) {
            return 0x0;
        }
        return _0x559d37(_0xb6d941, v, r, s);
    }

    // @dev Verifies if the message is signed by an address
    function _0x426bf3(bytes32 _0x810b17, string _0x6397fe, address _0x11afa9) public pure returns (bool) {
        require(_0x11afa9 != 0x0);

        return _0x11afa9 == _0xa89ddd(_0x810b17, _0x6397fe);
    }

    // @dev Converts an hexstring to bytes
    function _0x648fe4(string _0xe14a11) public pure returns (bytes) {
        uint _0xdf2d37 = bytes(_0xe14a11).length;
        require(_0xdf2d37 % 2 == 0);

        bytes memory _0xaf346d = bytes(new string(_0xdf2d37 / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < _0xdf2d37; i += 2) {
            s = _0x38d2e5(_0xe14a11, i, i + 1);
            r = _0x38d2e5(_0xe14a11, i + 1, i + 2);
            uint p = _0xe8bd3b(s) * 16 + _0xe8bd3b(r);
            _0xaf346d[k++] = _0x5a8ae4(p)[31];
        }
        return _0xaf346d;
    }

    // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
    function _0xe8bd3b(string _0x8d470f) public pure returns (uint) {
        bytes memory _0x86f06b = bytes(_0x8d470f);
        // bool decimals = false;
        if ((_0x86f06b[0] >= 48) && (_0x86f06b[0] <= 57)) {
            return uint(_0x86f06b[0]) - 48;
        } else if ((_0x86f06b[0] >= 65) && (_0x86f06b[0] <= 70)) {
            return uint(_0x86f06b[0]) - 55;
        } else if ((_0x86f06b[0] >= 97) && (_0x86f06b[0] <= 102)) {
            return uint(_0x86f06b[0]) - 87;
        } else {
            revert();
        }
    }

    // @dev Converts a uint to a bytes32
    // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
    function _0x5a8ae4(uint _0x77b079) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), _0x77b079)}
    }

    // @dev Hashes the signed message
    // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
    function _0x17539f(string _0x4139d0) public pure returns (bytes32) {
        uint _0xdf2d37 = bytes(_0x4139d0).length;
        require(_0xdf2d37 > 0);
        bytes memory _0x6fad22 = "\x19Ethereum Signed Message:\n";
        return _0x468a1a(abi._0xfb4673(_0x6fad22, _0xc14701(_0xdf2d37), _0x4139d0));
    }

    // @dev Converts a uint in a string
    function _0xc14701(uint _0x77b079) public pure returns (string _0x6c9676) {
        uint _0xdf2d37 = 0;
        uint m = _0x77b079 + 0;
        while (m != 0) {
            _0xdf2d37++;
            m /= 10;
        }
        bytes memory b = new bytes(_0xdf2d37);
        uint i = _0xdf2d37 - 1;
        while (_0x77b079 != 0) {
            uint _0x179776 = _0x77b079 % 10;
            _0x77b079 = _0x77b079 / 10;
            b[i--] = byte(48 + _0x179776);
        }
        _0x6c9676 = string(b);
    }

    // @dev extract a substring
    // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
    function _0x38d2e5(string _0x0bdaef, uint _0x4ea78d, uint _0xcaa744) public pure returns (string) {
        bytes memory _0x99bf82 = bytes(_0x0bdaef);
        require(_0x4ea78d <= _0xcaa744);
        require(_0x4ea78d >= 0);
        require(_0xcaa744 <= _0x99bf82.length);

        bytes memory _0x6f9af3 = new bytes(_0xcaa744 - _0x4ea78d);
        for (uint i = _0x4ea78d; i < _0xcaa744; i++) {
            _0x6f9af3[i - _0x4ea78d] = _0x99bf82[i];
        }
        return string(_0x6f9af3);
    }
}
contract StandardToken is Token {

    function transfer(address _0x5a8149, uint256 _0x39800b) public returns (bool _0x91ebf6) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0xce76c1[msg.sender] >= _0x39800b);
        _0xce76c1[msg.sender] -= _0x39800b;
        _0xce76c1[_0x5a8149] += _0x39800b;
        emit Transfer(msg.sender, _0x5a8149, _0x39800b);
        return true;
    }

    function _0x9d7a57(address _0xe9aabe, address _0x5a8149, uint256 _0x39800b) public returns (bool _0x91ebf6) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0xce76c1[_0xe9aabe] >= _0x39800b && _0xb570d0[_0xe9aabe][msg.sender] >= _0x39800b);
        _0xce76c1[_0x5a8149] += _0x39800b;
        _0xce76c1[_0xe9aabe] -= _0x39800b;
        _0xb570d0[_0xe9aabe][msg.sender] -= _0x39800b;
        emit Transfer(_0xe9aabe, _0x5a8149, _0x39800b);
        return true;
    }

    function _0x314878(address _0x0e1c1f) public constant returns (uint256 balance) {
        return _0xce76c1[_0x0e1c1f];
    }

    function _0xd2a040(address _0xc63f9e, uint256 _0x39800b) public returns (bool _0x91ebf6) {
        _0xb570d0[msg.sender][_0xc63f9e] = _0x39800b;
        emit Approval(msg.sender, _0xc63f9e, _0x39800b);
        return true;
    }

    function _0xdd0260(address _0x0e1c1f, address _0xc63f9e) public constant returns (uint256 _0x614721) {
      return _0xb570d0[_0x0e1c1f][_0xc63f9e];
    }

    mapping (address => uint256) _0xce76c1;
    mapping (address => mapping (address => uint256)) _0xb570d0;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */

    string public _0xcac33c;                   //fancy name: eg Simon Bucks
    uint8 public _0x1d8e46;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public _0xc2e8a6;                 //An identifier: eg SBX
    string public _0xcf045f = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    constructor(
        uint256 _0x730964,
        string _0x69069d,
        uint8 _0x025f33,
        string _0xd3fac2
        ) public {
        _0xce76c1[msg.sender] = _0x730964;               // Give the creator all initial tokens
        _0x0a751e = _0x730964;                        // Update total supply
        _0xcac33c = _0x69069d;                                   // Set the name for display purposes
        _0x1d8e46 = _0x025f33;                            // Amount of decimals for display purposes
        _0xc2e8a6 = _0xd3fac2;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function _0xb3a432(address _0xc63f9e, uint256 _0x39800b, bytes _0xb611cc) public returns (bool _0x91ebf6) {
        _0xb570d0[msg.sender][_0xc63f9e] = _0x39800b;
        emit Approval(msg.sender, _0xc63f9e, _0x39800b);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_0xc63f9e.call(bytes4(bytes32(_0x468a1a("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x39800b, this, _0xb611cc));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant VERSION = "0.0.1";

    uint256 public _0x9fcc09 = 0;

    event DidLCOpen (
        bytes32 indexed _0xbd09b7,
        address indexed _0xae4bb2,
        address indexed _0x536194,
        uint256 _0x9bc8ec,
        address _0xd1401c,
        uint256 _0x940483,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed _0xbd09b7,
        uint256 _0xb19aa0,
        uint256 _0x5ee33e
    );

    event DidLCDeposit (
        bytes32 indexed _0xbd09b7,
        address indexed _0x8f2607,
        uint256 _0x8829ab,
        bool _0x75bed7
    );

    event DidLCUpdateState (
        bytes32 indexed _0xbd09b7,
        uint256 _0x8d69ba,
        uint256 _0x26e9fc,
        uint256 _0x9bc8ec,
        uint256 _0x940483,
        uint256 _0xb19aa0,
        uint256 _0x5ee33e,
        bytes32 _0x2e6756,
        uint256 _0x650598
    );

    event DidLCClose (
        bytes32 indexed _0xbd09b7,
        uint256 _0x8d69ba,
        uint256 _0x9bc8ec,
        uint256 _0x940483,
        uint256 _0xb19aa0,
        uint256 _0x5ee33e
    );

    event DidVCInit (
        bytes32 indexed _0x0a1752,
        bytes32 indexed _0x84734b,
        bytes _0x58854e,
        uint256 _0x8d69ba,
        address _0xae4bb2,
        address _0xdbf87a,
        uint256 _0xe855f7,
        uint256 _0x4837e1
    );

    event DidVCSettle (
        bytes32 indexed _0x0a1752,
        bytes32 indexed _0x84734b,
        uint256 _0x700f11,
        uint256 _0x80f9d2,
        uint256 _0x7aa39b,
        address _0xa2e2c1,
        uint256 _0x0b2d96
    );

    event DidVCClose(
        bytes32 indexed _0x0a1752,
        bytes32 indexed _0x84734b,
        uint256 _0xe855f7,
        uint256 _0x4837e1
    );

    struct Channel {
        //TODO: figure out if it's better just to split arrays by balances/deposits instead of eth/erc20
        address[2] _0x99c4b5; // 0: partyA 1: partyI
        uint256[4] _0x7adc44; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
        uint256[4] _0xe8c113; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
        uint256[2] _0xf8e4d2; // 0: eth 1: tokens
        uint256 _0x8d69ba;
        uint256 _0xff4c78;
        bytes32 VCrootHash;
        uint256 LCopenTimeout;
        uint256 _0x650598; // when update LC times out
        bool _0xc5068e; // true when both parties have joined
        bool _0x14ed19;
        uint256 _0x29e85f;
        HumanStandardToken _0xd1401c;
    }

    // virtual-channel state
    struct VirtualChannel {
        bool _0xa7be8d;
        bool _0xbdbd05;
        uint256 _0x8d69ba;
        address _0xa2e2c1; // Initiator of challenge
        uint256 _0x0b2d96; // when update VC times out
        // channel state
        address _0xae4bb2; // VC participant A
        address _0xdbf87a; // VC participant B
        address _0x536194; // LC hub
        uint256[2] _0x7adc44;
        uint256[2] _0xe8c113;
        uint256[2] _0x4c710f;
        HumanStandardToken _0xd1401c;
    }

    mapping(bytes32 => VirtualChannel) public _0x073cb1;
    mapping(bytes32 => Channel) public Channels;

    function _0xa8645b(
        bytes32 _0x724a30,
        address _0x213142,
        uint256 _0x3df797,
        address _0xfa07b1,
        uint256[2] _0x7830c0 // [eth, token]
    )
        public
        payable
    {
        require(Channels[_0x724a30]._0x99c4b5[0] == address(0), "Channel has already been created.");
        require(_0x213142 != 0x0, "No partyI address provided to LC creation");
        require(_0x7830c0[0] >= 0 && _0x7830c0[1] >= 0, "Balances cannot be negative");
        // Set initial ledger channel state
        // Alice must execute this and we assume the initial state
        // to be signed from this requirement
        // Alternative is to check a sig as in joinChannel
        Channels[_0x724a30]._0x99c4b5[0] = msg.sender;
        Channels[_0x724a30]._0x99c4b5[1] = _0x213142;

        if(_0x7830c0[0] != 0) {
            require(msg.value == _0x7830c0[0], "Eth balance does not match sent value");
            Channels[_0x724a30]._0x7adc44[0] = msg.value;
        }
        if(_0x7830c0[1] != 0) {
            Channels[_0x724a30]._0xd1401c = HumanStandardToken(_0xfa07b1);
            require(Channels[_0x724a30]._0xd1401c._0x9d7a57(msg.sender, this, _0x7830c0[1]),"CreateChannel: token transfer failure");
            Channels[_0x724a30]._0xe8c113[0] = _0x7830c0[1];
        }

        Channels[_0x724a30]._0x8d69ba = 0;
        Channels[_0x724a30]._0xff4c78 = _0x3df797;
        // is close flag, lc state sequence, number open vc, vc root hash, partyA...
        //Channels[_lcID].stateHash = keccak256(uint256(0), uint256(0), uint256(0), bytes32(0x0), bytes32(msg.sender), bytes32(_partyI), balanceA, balanceI);
        Channels[_0x724a30].LCopenTimeout = _0xf3ca17 + _0x3df797;
        Channels[_0x724a30]._0xf8e4d2 = _0x7830c0;

        emit DidLCOpen(_0x724a30, msg.sender, _0x213142, _0x7830c0[0], _0xfa07b1, _0x7830c0[1], Channels[_0x724a30].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _0x724a30) public {
        require(msg.sender == Channels[_0x724a30]._0x99c4b5[0] && Channels[_0x724a30]._0xc5068e == false);
        require(_0xf3ca17 > Channels[_0x724a30].LCopenTimeout);

        if(Channels[_0x724a30]._0xf8e4d2[0] != 0) {
            Channels[_0x724a30]._0x99c4b5[0].transfer(Channels[_0x724a30]._0x7adc44[0]);
        }
        if(Channels[_0x724a30]._0xf8e4d2[1] != 0) {
            require(Channels[_0x724a30]._0xd1401c.transfer(Channels[_0x724a30]._0x99c4b5[0], Channels[_0x724a30]._0xe8c113[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_0x724a30, 0, Channels[_0x724a30]._0x7adc44[0], Channels[_0x724a30]._0xe8c113[0], 0, 0);

        // only safe to delete since no action was taken on this channel
        delete Channels[_0x724a30];
    }

    function _0x9d2b94(bytes32 _0x724a30, uint256[2] _0x7830c0) public payable {
        // require the channel is not open yet
        require(Channels[_0x724a30]._0xc5068e == false);
        require(msg.sender == Channels[_0x724a30]._0x99c4b5[1]);

        if(_0x7830c0[0] != 0) {
            require(msg.value == _0x7830c0[0], "state balance does not match sent value");
            Channels[_0x724a30]._0x7adc44[1] = msg.value;
        }
        if(_0x7830c0[1] != 0) {
            require(Channels[_0x724a30]._0xd1401c._0x9d7a57(msg.sender, this, _0x7830c0[1]),"joinChannel: token transfer failure");
            Channels[_0x724a30]._0xe8c113[1] = _0x7830c0[1];
        }

        Channels[_0x724a30]._0xf8e4d2[0]+=_0x7830c0[0];
        Channels[_0x724a30]._0xf8e4d2[1]+=_0x7830c0[1];
        // no longer allow joining functions to be called
        Channels[_0x724a30]._0xc5068e = true;
        _0x9fcc09++;

        emit DidLCJoin(_0x724a30, _0x7830c0[0], _0x7830c0[1]);
    }

    // additive updates of monetary state
    function _0x8829ab(bytes32 _0x724a30, address _0x8f2607, uint256 _0x844df5, bool _0x75bed7) public payable {
        require(Channels[_0x724a30]._0xc5068e == true, "Tried adding funds to a closed channel");
        require(_0x8f2607 == Channels[_0x724a30]._0x99c4b5[0] || _0x8f2607 == Channels[_0x724a30]._0x99c4b5[1]);

        //if(Channels[_lcID].token)

        if (Channels[_0x724a30]._0x99c4b5[0] == _0x8f2607) {
            if(_0x75bed7) {
                require(Channels[_0x724a30]._0xd1401c._0x9d7a57(msg.sender, this, _0x844df5),"deposit: token transfer failure");
                Channels[_0x724a30]._0xe8c113[2] += _0x844df5;
            } else {
                require(msg.value == _0x844df5, "state balance does not match sent value");
                Channels[_0x724a30]._0x7adc44[2] += msg.value;
            }
        }

        if (Channels[_0x724a30]._0x99c4b5[1] == _0x8f2607) {
            if(_0x75bed7) {
                require(Channels[_0x724a30]._0xd1401c._0x9d7a57(msg.sender, this, _0x844df5),"deposit: token transfer failure");
                Channels[_0x724a30]._0xe8c113[3] += _0x844df5;
            } else {
                require(msg.value == _0x844df5, "state balance does not match sent value");
                Channels[_0x724a30]._0x7adc44[3] += msg.value;
            }
        }

        emit DidLCDeposit(_0x724a30, _0x8f2607, _0x844df5, _0x75bed7);
    }

    // TODO: Check there are no open virtual channels, the client should have cought this before signing a close LC state update
    function _0x54dcda(
        bytes32 _0x724a30,
        uint256 _0xfa8979,
        uint256[4] _0x7830c0, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
        string _0x172a70,
        string _0x901a52
    )
        public
    {
        // assume num open vc is 0 and root hash is 0x0
        //require(Channels[_lcID].sequence < _sequence);
        require(Channels[_0x724a30]._0xc5068e == true);
        uint256 _0x9287db = Channels[_0x724a30]._0xf8e4d2[0] + Channels[_0x724a30]._0x7adc44[2] + Channels[_0x724a30]._0x7adc44[3];
        uint256 _0x9abb78 = Channels[_0x724a30]._0xf8e4d2[1] + Channels[_0x724a30]._0xe8c113[2] + Channels[_0x724a30]._0xe8c113[3];
        require(_0x9287db == _0x7830c0[0] + _0x7830c0[1]);
        require(_0x9abb78 == _0x7830c0[2] + _0x7830c0[3]);

        bytes32 _0x687003 = _0x468a1a(
            abi._0xfb4673(
                _0x724a30,
                true,
                _0xfa8979,
                uint256(0),
                bytes32(0x0),
                Channels[_0x724a30]._0x99c4b5[0],
                Channels[_0x724a30]._0x99c4b5[1],
                _0x7830c0[0],
                _0x7830c0[1],
                _0x7830c0[2],
                _0x7830c0[3]
            )
        );

        require(Channels[_0x724a30]._0x99c4b5[0] == ECTools._0xa89ddd(_0x687003, _0x172a70));
        require(Channels[_0x724a30]._0x99c4b5[1] == ECTools._0xa89ddd(_0x687003, _0x901a52));

        Channels[_0x724a30]._0xc5068e = false;

        if(_0x7830c0[0] != 0 || _0x7830c0[1] != 0) {
            Channels[_0x724a30]._0x99c4b5[0].transfer(_0x7830c0[0]);
            Channels[_0x724a30]._0x99c4b5[1].transfer(_0x7830c0[1]);
        }

        if(_0x7830c0[2] != 0 || _0x7830c0[3] != 0) {
            require(Channels[_0x724a30]._0xd1401c.transfer(Channels[_0x724a30]._0x99c4b5[0], _0x7830c0[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_0x724a30]._0xd1401c.transfer(Channels[_0x724a30]._0x99c4b5[1], _0x7830c0[3]),"happyCloseChannel: token transfer failure");
        }

        _0x9fcc09--;

        emit DidLCClose(_0x724a30, _0xfa8979, _0x7830c0[0], _0x7830c0[1], _0x7830c0[2], _0x7830c0[3]);
    }

    // Byzantine functions

    function _0xd442dd(
        bytes32 _0x724a30,
        uint256[6] _0x4af780, // [sequence, numOpenVc, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI]
        bytes32 _0xab5c72,
        string _0x172a70,
        string _0x901a52
    )
        public
    {
        Channel storage _0xf452d0 = Channels[_0x724a30];
        require(_0xf452d0._0xc5068e);
        require(_0xf452d0._0x8d69ba < _0x4af780[0]); // do same as vc sequence check
        require(_0xf452d0._0x7adc44[0] + _0xf452d0._0x7adc44[1] >= _0x4af780[2] + _0x4af780[3]);
        require(_0xf452d0._0xe8c113[0] + _0xf452d0._0xe8c113[1] >= _0x4af780[4] + _0x4af780[5]);

        if(_0xf452d0._0x14ed19 == true) {
            require(_0xf452d0._0x650598 > _0xf3ca17);
        }

        bytes32 _0x687003 = _0x468a1a(
            abi._0xfb4673(
                _0x724a30,
                false,
                _0x4af780[0],
                _0x4af780[1],
                _0xab5c72,
                _0xf452d0._0x99c4b5[0],
                _0xf452d0._0x99c4b5[1],
                _0x4af780[2],
                _0x4af780[3],
                _0x4af780[4],
                _0x4af780[5]
            )
        );

        require(_0xf452d0._0x99c4b5[0] == ECTools._0xa89ddd(_0x687003, _0x172a70));
        require(_0xf452d0._0x99c4b5[1] == ECTools._0xa89ddd(_0x687003, _0x901a52));

        // update LC state
        _0xf452d0._0x8d69ba = _0x4af780[0];
        _0xf452d0._0x29e85f = _0x4af780[1];
        _0xf452d0._0x7adc44[0] = _0x4af780[2];
        _0xf452d0._0x7adc44[1] = _0x4af780[3];
        _0xf452d0._0xe8c113[0] = _0x4af780[4];
        _0xf452d0._0xe8c113[1] = _0x4af780[5];
        _0xf452d0.VCrootHash = _0xab5c72;
        _0xf452d0._0x14ed19 = true;
        _0xf452d0._0x650598 = _0xf3ca17 + _0xf452d0._0xff4c78;

        // make settlement flag

        emit DidLCUpdateState (
            _0x724a30,
            _0x4af780[0],
            _0x4af780[1],
            _0x4af780[2],
            _0x4af780[3],
            _0x4af780[4],
            _0x4af780[5],
            _0xab5c72,
            _0xf452d0._0x650598
        );
    }

    // supply initial state of VC to "prime" the force push game
    function _0x4475b8(
        bytes32 _0x724a30,
        bytes32 _0x2bafde,
        bytes _0x511d9d,
        address _0x43d432,
        address _0x4b8f82,
        uint256[2] _0xecf95f,
        uint256[4] _0x7830c0, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
        string _0xd256fc
    )
        public
    {
        require(Channels[_0x724a30]._0xc5068e, "LC is closed.");
        // sub-channel must be open
        require(!_0x073cb1[_0x2bafde]._0xa7be8d, "VC is closed.");
        // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
        require(Channels[_0x724a30]._0x650598 < _0xf3ca17, "LC timeout not over.");
        // prevent rentry of initializing vc state
        require(_0x073cb1[_0x2bafde]._0x0b2d96 == 0);
        // partyB is now Ingrid
        bytes32 _0x978e9b = _0x468a1a(
            abi._0xfb4673(_0x2bafde, uint256(0), _0x43d432, _0x4b8f82, _0xecf95f[0], _0xecf95f[1], _0x7830c0[0], _0x7830c0[1], _0x7830c0[2], _0x7830c0[3])
        );

        // Make sure Alice has signed initial vc state (A/B in oldState)
        require(_0x43d432 == ECTools._0xa89ddd(_0x978e9b, _0xd256fc));

        // Check the oldState is in the root hash
        require(_0xb55c3b(_0x978e9b, _0x511d9d, Channels[_0x724a30].VCrootHash) == true);

        _0x073cb1[_0x2bafde]._0xae4bb2 = _0x43d432; // VC participant A
        _0x073cb1[_0x2bafde]._0xdbf87a = _0x4b8f82; // VC participant B
        _0x073cb1[_0x2bafde]._0x8d69ba = uint256(0);
        _0x073cb1[_0x2bafde]._0x7adc44[0] = _0x7830c0[0];
        _0x073cb1[_0x2bafde]._0x7adc44[1] = _0x7830c0[1];
        _0x073cb1[_0x2bafde]._0xe8c113[0] = _0x7830c0[2];
        _0x073cb1[_0x2bafde]._0xe8c113[1] = _0x7830c0[3];
        _0x073cb1[_0x2bafde]._0x4c710f = _0xecf95f;
        _0x073cb1[_0x2bafde]._0x0b2d96 = _0xf3ca17 + Channels[_0x724a30]._0xff4c78;
        _0x073cb1[_0x2bafde]._0xbdbd05 = true;

        emit DidVCInit(_0x724a30, _0x2bafde, _0x511d9d, uint256(0), _0x43d432, _0x4b8f82, _0x7830c0[0], _0x7830c0[1]);
    }

    //TODO: verify state transition since the hub did not agree to this state
    // make sure the A/B balances are not beyond ingrids bonds
    // Params: vc init state, vc final balance, vcID
    function _0x861e11(
        bytes32 _0x724a30,
        bytes32 _0x2bafde,
        uint256 _0x700f11,
        address _0x43d432,
        address _0x4b8f82,
        uint256[4] _0x219e09, // [ethupdateBalA, ethupdateBalB, tokenupdateBalA, tokenupdateBalB]
        string _0xd256fc
    )
        public
    {
        require(Channels[_0x724a30]._0xc5068e, "LC is closed.");
        // sub-channel must be open
        require(!_0x073cb1[_0x2bafde]._0xa7be8d, "VC is closed.");
        require(_0x073cb1[_0x2bafde]._0x8d69ba < _0x700f11, "VC sequence is higher than update sequence.");
        require(
            _0x073cb1[_0x2bafde]._0x7adc44[1] < _0x219e09[1] && _0x073cb1[_0x2bafde]._0xe8c113[1] < _0x219e09[3],
            "State updates may only increase recipient balance."
        );
        require(
            _0x073cb1[_0x2bafde]._0x4c710f[0] == _0x219e09[0] + _0x219e09[1] &&
            _0x073cb1[_0x2bafde]._0x4c710f[1] == _0x219e09[2] + _0x219e09[3],
            "Incorrect balances for bonded amount");
        // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
        // virtualChannels[_vcID].updateVCtimeout should be 0 on uninitialized vc state, and this should
        // fail if initVC() isn't called first
        // require(Channels[_lcID].updateLCtimeout < now && now < virtualChannels[_vcID].updateVCtimeout);
        require(Channels[_0x724a30]._0x650598 < _0xf3ca17); // for testing!

        bytes32 _0xc6adbc = _0x468a1a(
            abi._0xfb4673(
                _0x2bafde,
                _0x700f11,
                _0x43d432,
                _0x4b8f82,
                _0x073cb1[_0x2bafde]._0x4c710f[0],
                _0x073cb1[_0x2bafde]._0x4c710f[1],
                _0x219e09[0],
                _0x219e09[1],
                _0x219e09[2],
                _0x219e09[3]
            )
        );

        // Make sure Alice has signed a higher sequence new state
        require(_0x073cb1[_0x2bafde]._0xae4bb2 == ECTools._0xa89ddd(_0xc6adbc, _0xd256fc));

        // store VC data
        // we may want to record who is initiating on-chain settles
        _0x073cb1[_0x2bafde]._0xa2e2c1 = msg.sender;
        _0x073cb1[_0x2bafde]._0x8d69ba = _0x700f11;

        // channel state
        _0x073cb1[_0x2bafde]._0x7adc44[0] = _0x219e09[0];
        _0x073cb1[_0x2bafde]._0x7adc44[1] = _0x219e09[1];
        _0x073cb1[_0x2bafde]._0xe8c113[0] = _0x219e09[2];
        _0x073cb1[_0x2bafde]._0xe8c113[1] = _0x219e09[3];

        _0x073cb1[_0x2bafde]._0x0b2d96 = _0xf3ca17 + Channels[_0x724a30]._0xff4c78;

        emit DidVCSettle(_0x724a30, _0x2bafde, _0x700f11, _0x219e09[0], _0x219e09[1], msg.sender, _0x073cb1[_0x2bafde]._0x0b2d96);
    }

    function _0x8c4ea8(bytes32 _0x724a30, bytes32 _0x2bafde) public {
        // require(updateLCtimeout > now)
        require(Channels[_0x724a30]._0xc5068e, "LC is closed.");
        require(_0x073cb1[_0x2bafde]._0xbdbd05, "VC is not in settlement state.");
        require(_0x073cb1[_0x2bafde]._0x0b2d96 < _0xf3ca17, "Update vc timeout has not elapsed.");
        require(!_0x073cb1[_0x2bafde]._0xa7be8d, "VC is already closed");
        // reduce the number of open virtual channels stored on LC
        Channels[_0x724a30]._0x29e85f--;
        // close vc flags
        _0x073cb1[_0x2bafde]._0xa7be8d = true;
        // re-introduce the balances back into the LC state from the settled VC
        // decide if this lc is alice or bob in the vc
        if(_0x073cb1[_0x2bafde]._0xae4bb2 == Channels[_0x724a30]._0x99c4b5[0]) {
            Channels[_0x724a30]._0x7adc44[0] += _0x073cb1[_0x2bafde]._0x7adc44[0];
            Channels[_0x724a30]._0x7adc44[1] += _0x073cb1[_0x2bafde]._0x7adc44[1];

            Channels[_0x724a30]._0xe8c113[0] += _0x073cb1[_0x2bafde]._0xe8c113[0];
            Channels[_0x724a30]._0xe8c113[1] += _0x073cb1[_0x2bafde]._0xe8c113[1];
        } else if (_0x073cb1[_0x2bafde]._0xdbf87a == Channels[_0x724a30]._0x99c4b5[0]) {
            Channels[_0x724a30]._0x7adc44[0] += _0x073cb1[_0x2bafde]._0x7adc44[1];
            Channels[_0x724a30]._0x7adc44[1] += _0x073cb1[_0x2bafde]._0x7adc44[0];

            Channels[_0x724a30]._0xe8c113[0] += _0x073cb1[_0x2bafde]._0xe8c113[1];
            Channels[_0x724a30]._0xe8c113[1] += _0x073cb1[_0x2bafde]._0xe8c113[0];
        }

        emit DidVCClose(_0x724a30, _0x2bafde, _0x073cb1[_0x2bafde]._0xe8c113[0], _0x073cb1[_0x2bafde]._0xe8c113[1]);
    }

    // todo: allow ethier lc.end-user to nullify the settled LC state and return to off-chain
    function _0xbef2d4(bytes32 _0x724a30) public {
        Channel storage _0xf452d0 = Channels[_0x724a30];

        // check settlement flag
        require(_0xf452d0._0xc5068e, "Channel is not open");
        require(_0xf452d0._0x14ed19 == true);
        require(_0xf452d0._0x29e85f == 0);
        require(_0xf452d0._0x650598 < _0xf3ca17, "LC timeout over.");

        // if off chain state update didnt reblance deposits, just return to deposit owner
        uint256 _0x9287db = _0xf452d0._0xf8e4d2[0] + _0xf452d0._0x7adc44[2] + _0xf452d0._0x7adc44[3];
        uint256 _0x9abb78 = _0xf452d0._0xf8e4d2[1] + _0xf452d0._0xe8c113[2] + _0xf452d0._0xe8c113[3];

        uint256 _0x40711c = _0xf452d0._0x7adc44[0] + _0xf452d0._0x7adc44[1];
        uint256 _0xe215a9 = _0xf452d0._0xe8c113[0] + _0xf452d0._0xe8c113[1];

        if(_0x40711c < _0x9287db) {
            _0xf452d0._0x7adc44[0]+=_0xf452d0._0x7adc44[2];
            _0xf452d0._0x7adc44[1]+=_0xf452d0._0x7adc44[3];
        } else {
            require(_0x40711c == _0x9287db);
        }

        if(_0xe215a9 < _0x9abb78) {
            _0xf452d0._0xe8c113[0]+=_0xf452d0._0xe8c113[2];
            _0xf452d0._0xe8c113[1]+=_0xf452d0._0xe8c113[3];
        } else {
            require(_0xe215a9 == _0x9abb78);
        }

        uint256 _0x896e19 = _0xf452d0._0x7adc44[0];
        uint256 _0x3c4069 = _0xf452d0._0x7adc44[1];
        uint256 _0x3e3557 = _0xf452d0._0xe8c113[0];
        uint256 _0x96d29b = _0xf452d0._0xe8c113[1];

        _0xf452d0._0x7adc44[0] = 0;
        _0xf452d0._0x7adc44[1] = 0;
        _0xf452d0._0xe8c113[0] = 0;
        _0xf452d0._0xe8c113[1] = 0;

        if(_0x896e19 != 0 || _0x3c4069 != 0) {
            _0xf452d0._0x99c4b5[0].transfer(_0x896e19);
            _0xf452d0._0x99c4b5[1].transfer(_0x3c4069);
        }

        if(_0x3e3557 != 0 || _0x96d29b != 0) {
            require(
                _0xf452d0._0xd1401c.transfer(_0xf452d0._0x99c4b5[0], _0x3e3557),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                _0xf452d0._0xd1401c.transfer(_0xf452d0._0x99c4b5[1], _0x96d29b),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        _0xf452d0._0xc5068e = false;
        _0x9fcc09--;

        emit DidLCClose(_0x724a30, _0xf452d0._0x8d69ba, _0x896e19, _0x3c4069, _0x3e3557, _0x96d29b);
    }

    function _0xb55c3b(bytes32 _0x4221c0, bytes _0x511d9d, bytes32 _0x41fa19) internal pure returns (bool) {
        bytes32 _0xad04a8 = _0x4221c0;
        bytes32 _0xd5d4ec;

        for (uint256 i = 64; i <= _0x511d9d.length; i += 32) {
            assembly { _0xd5d4ec := mload(add(_0x511d9d, i)) }

            if (_0xad04a8 < _0xd5d4ec) {
                _0xad04a8 = _0x468a1a(abi._0xfb4673(_0xad04a8, _0xd5d4ec));
            } else {
                _0xad04a8 = _0x468a1a(abi._0xfb4673(_0xd5d4ec, _0xad04a8));
            }
        }

        return _0xad04a8 == _0x41fa19;
    }

    //Struct Getters
    function _0x410c60(bytes32 _0xcd886e) public view returns (
        address[2],
        uint256[4],
        uint256[4],
        uint256[2],
        uint256,
        uint256,
        bytes32,
        uint256,
        uint256,
        bool,
        bool,
        uint256
    ) {
        Channel memory _0xf452d0 = Channels[_0xcd886e];
        return (
            _0xf452d0._0x99c4b5,
            _0xf452d0._0x7adc44,
            _0xf452d0._0xe8c113,
            _0xf452d0._0xf8e4d2,
            _0xf452d0._0x8d69ba,
            _0xf452d0._0xff4c78,
            _0xf452d0.VCrootHash,
            _0xf452d0.LCopenTimeout,
            _0xf452d0._0x650598,
            _0xf452d0._0xc5068e,
            _0xf452d0._0x14ed19,
            _0xf452d0._0x29e85f
        );
    }

    function _0xbcd8f9(bytes32 _0xcd886e) public view returns(
        bool,
        bool,
        uint256,
        address,
        uint256,
        address,
        address,
        address,
        uint256[2],
        uint256[2],
        uint256[2]
    ) {
        VirtualChannel memory _0xede0cf = _0x073cb1[_0xcd886e];
        return(
            _0xede0cf._0xa7be8d,
            _0xede0cf._0xbdbd05,
            _0xede0cf._0x8d69ba,
            _0xede0cf._0xa2e2c1,
            _0xede0cf._0x0b2d96,
            _0xede0cf._0xae4bb2,
            _0xede0cf._0xdbf87a,
            _0xede0cf._0x536194,
            _0xede0cf._0x7adc44,
            _0xede0cf._0xe8c113,
            _0xede0cf._0x4c710f
        );
    }
}