 pragma solidity ^0.4.23;
 // produced by the Solididy File Flattener (c) David Appleton 2018
 // contact : dave@akomba.com
 // released under Apache 2.0 licence
 contract Token {
     /// total amount of tokens
     uint256 public _0x7e88da;

     /// @param _owner The address from which the balance will be retrieved
     /// @return The balance
     function _0x163805(address _0x77a491) public constant returns (uint256 balance);

     /// @notice send `_value` token to `_to` from `msg.sender`
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function transfer(address _0x5ab6ac, uint256 _0xc11352) public returns (bool _0x4d1c5a);

     /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     /// @param _from The address of the sender
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function _0xd4b040(address _0x64b841, address _0x5ab6ac, uint256 _0xc11352) public returns (bool _0x4d1c5a);

     /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @param _value The amount of tokens to be approved for transfer
     /// @return Whether the approval was successful or not
     function _0x60e96c(address _0x6d5af0, uint256 _0xc11352) public returns (bool _0x4d1c5a);

     /// @param _owner The address of the account owning tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @return Amount of remaining tokens allowed to spent
     function _0x74647e(address _0x77a491, address _0x6d5af0) public constant returns (uint256 _0xcbb745);

     event Transfer(address indexed _0x64b841, address indexed _0x5ab6ac, uint256 _0xc11352);
     event Approval(address indexed _0x77a491, address indexed _0x6d5af0, uint256 _0xc11352);
 }

 library ECTools {

     // @dev Recovers the address which has signed a message
     // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
     function _0x8c5fd8(bytes32 _0xa2bd2d, string _0x1dfbcc) public pure returns (address) {
         require(_0xa2bd2d != 0x00);

         // need this for test RPC
         bytes memory _0x260f01 = "\x19Ethereum Signed Message:\n32";
         bytes32 _0x94b463 = _0x46f92f(abi._0xba3392(_0x260f01, _0xa2bd2d));

         if (bytes(_0x1dfbcc).length != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = _0xe67bb7(_0xd39196(_0x1dfbcc, 2, 132));
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
         return _0x8fcd25(_0x94b463, v, r, s);
     }

     // @dev Verifies if the message is signed by an address
     function _0xfc7fc7(bytes32 _0xa2bd2d, string _0x1dfbcc, address _0x8b8818) public pure returns (bool) {
         require(_0x8b8818 != 0x0);

         return _0x8b8818 == _0x8c5fd8(_0xa2bd2d, _0x1dfbcc);
     }

     // @dev Converts an hexstring to bytes
     function _0xe67bb7(string _0x7fd4e2) public pure returns (bytes) {
         uint _0x59af36 = bytes(_0x7fd4e2).length;
         require(_0x59af36 % 2 == 0);

         bytes memory _0x11a698 = bytes(new string(_0x59af36 / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < _0x59af36; i += 2) {
             s = _0xd39196(_0x7fd4e2, i, i + 1);
             r = _0xd39196(_0x7fd4e2, i + 1, i + 2);
             uint p = _0xd0bc8a(s) * 16 + _0xd0bc8a(r);
             _0x11a698[k++] = _0x2995a9(p)[31];
         }
         return _0x11a698;
     }

     // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
     function _0xd0bc8a(string _0xd65cc4) public pure returns (uint) {
         bytes memory _0xa1b3d3 = bytes(_0xd65cc4);
         // bool decimals = false;
         if ((_0xa1b3d3[0] >= 48) && (_0xa1b3d3[0] <= 57)) {
             return uint(_0xa1b3d3[0]) - 48;
         } else if ((_0xa1b3d3[0] >= 65) && (_0xa1b3d3[0] <= 70)) {
             return uint(_0xa1b3d3[0]) - 55;
         } else if ((_0xa1b3d3[0] >= 97) && (_0xa1b3d3[0] <= 102)) {
             return uint(_0xa1b3d3[0]) - 87;
         } else {
             revert();
         }
     }

     // @dev Converts a uint to a bytes32
     // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
     function _0x2995a9(uint _0x89b00b) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(add(b, 32), _0x89b00b)}
     }

     // @dev Hashes the signed message
     // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
     function _0x36a608(string _0xa413be) public pure returns (bytes32) {
         uint _0x59af36 = bytes(_0xa413be).length;
         require(_0x59af36 > 0);
         bytes memory _0x260f01 = "\x19Ethereum Signed Message:\n";
         return _0x46f92f(abi._0xba3392(_0x260f01, _0xaf5802(_0x59af36), _0xa413be));
     }

     // @dev Converts a uint in a string
     function _0xaf5802(uint _0x89b00b) public pure returns (string _0xfa622f) {
         uint _0x59af36 = 0;
         uint m = _0x89b00b + 0;
         while (m != 0) {
             _0x59af36++;
             m /= 10;
         }
         bytes memory b = new bytes(_0x59af36);
         uint i = _0x59af36 - 1;
         while (_0x89b00b != 0) {
             uint _0x13b853 = _0x89b00b % 10;
             _0x89b00b = _0x89b00b / 10;
             b[i--] = byte(48 + _0x13b853);
         }
         _0xfa622f = string(b);
     }

     // @dev extract a substring
     // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
     function _0xd39196(string _0x7f4f5b, uint _0xdacec8, uint _0x5c81f1) public pure returns (string) {
         bytes memory _0x6492f3 = bytes(_0x7f4f5b);
         require(_0xdacec8 <= _0x5c81f1);
         require(_0xdacec8 >= 0);
         require(_0x5c81f1 <= _0x6492f3.length);

         bytes memory _0xf01c20 = new bytes(_0x5c81f1 - _0xdacec8);
         for (uint i = _0xdacec8; i < _0x5c81f1; i++) {
             _0xf01c20[i - _0xdacec8] = _0x6492f3[i];
         }
         return string(_0xf01c20);
     }
 }
 contract StandardToken is Token {

     function transfer(address _0x5ab6ac, uint256 _0xc11352) public returns (bool _0x4d1c5a) {
         //Default assumes totalSupply can't be over max (2^256 - 1).
         //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
         //Replace the if with this one instead.
         //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
         require(_0x0edf87[msg.sender] >= _0xc11352);
         _0x0edf87[msg.sender] -= _0xc11352;
         _0x0edf87[_0x5ab6ac] += _0xc11352;
         emit Transfer(msg.sender, _0x5ab6ac, _0xc11352);
         return true;
     }

     function _0xd4b040(address _0x64b841, address _0x5ab6ac, uint256 _0xc11352) public returns (bool _0x4d1c5a) {

         //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
         require(_0x0edf87[_0x64b841] >= _0xc11352 && _0x3494fc[_0x64b841][msg.sender] >= _0xc11352);
         _0x0edf87[_0x5ab6ac] += _0xc11352;
         _0x0edf87[_0x64b841] -= _0xc11352;
         _0x3494fc[_0x64b841][msg.sender] -= _0xc11352;
         emit Transfer(_0x64b841, _0x5ab6ac, _0xc11352);
         return true;
     }

     function _0x163805(address _0x77a491) public constant returns (uint256 balance) {
         return _0x0edf87[_0x77a491];
     }

     function _0x60e96c(address _0x6d5af0, uint256 _0xc11352) public returns (bool _0x4d1c5a) {
         _0x3494fc[msg.sender][_0x6d5af0] = _0xc11352;
         emit Approval(msg.sender, _0x6d5af0, _0xc11352);
         return true;
     }

     function _0x74647e(address _0x77a491, address _0x6d5af0) public constant returns (uint256 _0xcbb745) {
       return _0x3494fc[_0x77a491][_0x6d5af0];
     }

     mapping (address => uint256) _0x0edf87;
     mapping (address => mapping (address => uint256)) _0x3494fc;
 }

 contract HumanStandardToken is StandardToken {

     /* Public variables of the token */

     string public _0x043290;                   //fancy name: eg Simon Bucks
     uint8 public _0xca2a7a;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
     string public _0x45e9cc;                 //An identifier: eg SBX
     string public _0x018c6b = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

     constructor(
         uint256 _0x1dcaa5,
         string _0xfcbb73,
         uint8 _0x2a9071,
         string _0xfac1fd
         ) public {
         _0x0edf87[msg.sender] = _0x1dcaa5;               // Give the creator all initial tokens
         _0x7e88da = _0x1dcaa5;                        // Update total supply
         _0x043290 = _0xfcbb73;                                   // Set the name for display purposes
         _0xca2a7a = _0x2a9071;                            // Amount of decimals for display purposes
         _0x45e9cc = _0xfac1fd;                               // Set the symbol for display purposes
     }

     /* Approves and then calls the receiving contract */
     function _0xc67e95(address _0x6d5af0, uint256 _0xc11352, bytes _0x439485) public returns (bool _0x4d1c5a) {
         _0x3494fc[msg.sender][_0x6d5af0] = _0xc11352;
         emit Approval(msg.sender, _0x6d5af0, _0xc11352);

         //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
         //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
         //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
         require(_0x6d5af0.call(bytes4(bytes32(_0x46f92f("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0xc11352, this, _0x439485));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant VERSION = "0.0.1";

     uint256 public _0xa0131a = 0;

     event DidLCOpen (
         bytes32 indexed _0xaf2ae6,
         address indexed _0xd58a9f,
         address indexed _0x4868cf,
         uint256 _0x1b58c9,
         address _0x06be49,
         uint256 _0x143121,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed _0xaf2ae6,
         uint256 _0xa7a483,
         uint256 _0xb945f6
     );

     event DidLCDeposit (
         bytes32 indexed _0xaf2ae6,
         address indexed _0xabdf35,
         uint256 _0x5f2a5d,
         bool _0x5facfb
     );

     event DidLCUpdateState (
         bytes32 indexed _0xaf2ae6,
         uint256 _0xf38ac6,
         uint256 _0x0b7ffa,
         uint256 _0x1b58c9,
         uint256 _0x143121,
         uint256 _0xa7a483,
         uint256 _0xb945f6,
         bytes32 _0xd4c734,
         uint256 _0x5ed680
     );

     event DidLCClose (
         bytes32 indexed _0xaf2ae6,
         uint256 _0xf38ac6,
         uint256 _0x1b58c9,
         uint256 _0x143121,
         uint256 _0xa7a483,
         uint256 _0xb945f6
     );

     event DidVCInit (
         bytes32 indexed _0xf9f089,
         bytes32 indexed _0xe2b694,
         bytes _0x185d6f,
         uint256 _0xf38ac6,
         address _0xd58a9f,
         address _0xb95393,
         uint256 _0xfb80ad,
         uint256 _0x3125a1
     );

     event DidVCSettle (
         bytes32 indexed _0xf9f089,
         bytes32 indexed _0xe2b694,
         uint256 _0x305e0d,
         uint256 _0x8ac7cc,
         uint256 _0x5bc333,
         address _0x01d008,
         uint256 _0x09f372
     );

     event DidVCClose(
         bytes32 indexed _0xf9f089,
         bytes32 indexed _0xe2b694,
         uint256 _0xfb80ad,
         uint256 _0x3125a1
     );

     struct Channel {
         //TODO: figure out if it's better just to split arrays by balances/deposits instead of eth/erc20
         address[2] _0x61b15b; // 0: partyA 1: partyI
         uint256[4] _0x9d66dc; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
         uint256[4] _0xab08c0; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
         uint256[2] _0xee9f70; // 0: eth 1: tokens
         uint256 _0xf38ac6;
         uint256 _0xccd1b0;
         bytes32 VCrootHash;
         uint256 LCopenTimeout;
         uint256 _0x5ed680; // when update LC times out
         bool _0x16ff5d; // true when both parties have joined
         bool _0xf4e517;
         uint256 _0x9fe1f8;
         HumanStandardToken _0x06be49;
     }

     // virtual-channel state
     struct VirtualChannel {
         bool _0x1c1905;
         bool _0x0cf94d;
         uint256 _0xf38ac6;
         address _0x01d008; // Initiator of challenge
         uint256 _0x09f372; // when update VC times out
         // channel state
         address _0xd58a9f; // VC participant A
         address _0xb95393; // VC participant B
         address _0x4868cf; // LC hub
         uint256[2] _0x9d66dc;
         uint256[2] _0xab08c0;
         uint256[2] _0xf2dd38;
         HumanStandardToken _0x06be49;
     }

     mapping(bytes32 => VirtualChannel) public _0xf3dbcf;
     mapping(bytes32 => Channel) public Channels;

     function _0x2bb8ed(
         bytes32 _0x356be4,
         address _0xe7ef82,
         uint256 _0x845b0f,
         address _0x6cd989,
         uint256[2] _0xed3f77 // [eth, token]
     )
         public
         payable
     {
         require(Channels[_0x356be4]._0x61b15b[0] == address(0), "Channel has already been created.");
         require(_0xe7ef82 != 0x0, "No partyI address provided to LC creation");
         require(_0xed3f77[0] >= 0 && _0xed3f77[1] >= 0, "Balances cannot be negative");
         // Set initial ledger channel state
         // Alice must execute this and we assume the initial state
         // to be signed from this requirement
         // Alternative is to check a sig as in joinChannel
         Channels[_0x356be4]._0x61b15b[0] = msg.sender;
         Channels[_0x356be4]._0x61b15b[1] = _0xe7ef82;

         if(_0xed3f77[0] != 0) {
             require(msg.value == _0xed3f77[0], "Eth balance does not match sent value");
             Channels[_0x356be4]._0x9d66dc[0] = msg.value;
         }
         if(_0xed3f77[1] != 0) {
             Channels[_0x356be4]._0x06be49 = HumanStandardToken(_0x6cd989);
             require(Channels[_0x356be4]._0x06be49._0xd4b040(msg.sender, this, _0xed3f77[1]),"CreateChannel: token transfer failure");
             Channels[_0x356be4]._0xab08c0[0] = _0xed3f77[1];
         }

         Channels[_0x356be4]._0xf38ac6 = 0;
         Channels[_0x356be4]._0xccd1b0 = _0x845b0f;
         // is close flag, lc state sequence, number open vc, vc root hash, partyA...
         //Channels[_lcID].stateHash = keccak256(uint256(0), uint256(0), uint256(0), bytes32(0x0), bytes32(msg.sender), bytes32(_partyI), balanceA, balanceI);
         Channels[_0x356be4].LCopenTimeout = _0xe09844 + _0x845b0f;
         Channels[_0x356be4]._0xee9f70 = _0xed3f77;

         emit DidLCOpen(_0x356be4, msg.sender, _0xe7ef82, _0xed3f77[0], _0x6cd989, _0xed3f77[1], Channels[_0x356be4].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _0x356be4) public {
         require(msg.sender == Channels[_0x356be4]._0x61b15b[0] && Channels[_0x356be4]._0x16ff5d == false);
         require(_0xe09844 > Channels[_0x356be4].LCopenTimeout);

         if(Channels[_0x356be4]._0xee9f70[0] != 0) {
             Channels[_0x356be4]._0x61b15b[0].transfer(Channels[_0x356be4]._0x9d66dc[0]);
         }
         if(Channels[_0x356be4]._0xee9f70[1] != 0) {
             require(Channels[_0x356be4]._0x06be49.transfer(Channels[_0x356be4]._0x61b15b[0], Channels[_0x356be4]._0xab08c0[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_0x356be4, 0, Channels[_0x356be4]._0x9d66dc[0], Channels[_0x356be4]._0xab08c0[0], 0, 0);

         // only safe to delete since no action was taken on this channel
         delete Channels[_0x356be4];
     }

     function _0xe3fda0(bytes32 _0x356be4, uint256[2] _0xed3f77) public payable {
         // require the channel is not open yet
         require(Channels[_0x356be4]._0x16ff5d == false);
         require(msg.sender == Channels[_0x356be4]._0x61b15b[1]);

         if(_0xed3f77[0] != 0) {
             require(msg.value == _0xed3f77[0], "state balance does not match sent value");
             Channels[_0x356be4]._0x9d66dc[1] = msg.value;
         }
         if(_0xed3f77[1] != 0) {
             require(Channels[_0x356be4]._0x06be49._0xd4b040(msg.sender, this, _0xed3f77[1]),"joinChannel: token transfer failure");
             Channels[_0x356be4]._0xab08c0[1] = _0xed3f77[1];
         }

         Channels[_0x356be4]._0xee9f70[0]+=_0xed3f77[0];
         Channels[_0x356be4]._0xee9f70[1]+=_0xed3f77[1];
         // no longer allow joining functions to be called
         Channels[_0x356be4]._0x16ff5d = true;
         _0xa0131a++;

         emit DidLCJoin(_0x356be4, _0xed3f77[0], _0xed3f77[1]);
     }

     // additive updates of monetary state
     function _0x5f2a5d(bytes32 _0x356be4, address _0xabdf35, uint256 _0xc7230f, bool _0x5facfb) public payable {
         require(Channels[_0x356be4]._0x16ff5d == true, "Tried adding funds to a closed channel");
         require(_0xabdf35 == Channels[_0x356be4]._0x61b15b[0] || _0xabdf35 == Channels[_0x356be4]._0x61b15b[1]);

         //if(Channels[_lcID].token)

         if (Channels[_0x356be4]._0x61b15b[0] == _0xabdf35) {
             if(_0x5facfb) {
                 require(Channels[_0x356be4]._0x06be49._0xd4b040(msg.sender, this, _0xc7230f),"deposit: token transfer failure");
                 Channels[_0x356be4]._0xab08c0[2] += _0xc7230f;
             } else {
                 require(msg.value == _0xc7230f, "state balance does not match sent value");
                 Channels[_0x356be4]._0x9d66dc[2] += msg.value;
             }
         }

         if (Channels[_0x356be4]._0x61b15b[1] == _0xabdf35) {
             if(_0x5facfb) {
                 require(Channels[_0x356be4]._0x06be49._0xd4b040(msg.sender, this, _0xc7230f),"deposit: token transfer failure");
                 Channels[_0x356be4]._0xab08c0[3] += _0xc7230f;
             } else {
                 require(msg.value == _0xc7230f, "state balance does not match sent value");
                 Channels[_0x356be4]._0x9d66dc[3] += msg.value;
             }
         }

         emit DidLCDeposit(_0x356be4, _0xabdf35, _0xc7230f, _0x5facfb);
     }

     // TODO: Check there are no open virtual channels, the client should have cought this before signing a close LC state update
     function _0xecafd8(
         bytes32 _0x356be4,
         uint256 _0xbc2cef,
         uint256[4] _0xed3f77, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
         string _0xbc734f,
         string _0x1a2b43
     )
         public
     {
         // assume num open vc is 0 and root hash is 0x0
         //require(Channels[_lcID].sequence < _sequence);
         require(Channels[_0x356be4]._0x16ff5d == true);
         uint256 _0x4d78c0 = Channels[_0x356be4]._0xee9f70[0] + Channels[_0x356be4]._0x9d66dc[2] + Channels[_0x356be4]._0x9d66dc[3];
         uint256 _0x03ba76 = Channels[_0x356be4]._0xee9f70[1] + Channels[_0x356be4]._0xab08c0[2] + Channels[_0x356be4]._0xab08c0[3];
         require(_0x4d78c0 == _0xed3f77[0] + _0xed3f77[1]);
         require(_0x03ba76 == _0xed3f77[2] + _0xed3f77[3]);

         bytes32 _0x56dd31 = _0x46f92f(
             abi._0xba3392(
                 _0x356be4,
                 true,
                 _0xbc2cef,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_0x356be4]._0x61b15b[0],
                 Channels[_0x356be4]._0x61b15b[1],
                 _0xed3f77[0],
                 _0xed3f77[1],
                 _0xed3f77[2],
                 _0xed3f77[3]
             )
         );

         require(Channels[_0x356be4]._0x61b15b[0] == ECTools._0x8c5fd8(_0x56dd31, _0xbc734f));
         require(Channels[_0x356be4]._0x61b15b[1] == ECTools._0x8c5fd8(_0x56dd31, _0x1a2b43));

         Channels[_0x356be4]._0x16ff5d = false;

         if(_0xed3f77[0] != 0 || _0xed3f77[1] != 0) {
             Channels[_0x356be4]._0x61b15b[0].transfer(_0xed3f77[0]);
             Channels[_0x356be4]._0x61b15b[1].transfer(_0xed3f77[1]);
         }

         if(_0xed3f77[2] != 0 || _0xed3f77[3] != 0) {
             require(Channels[_0x356be4]._0x06be49.transfer(Channels[_0x356be4]._0x61b15b[0], _0xed3f77[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_0x356be4]._0x06be49.transfer(Channels[_0x356be4]._0x61b15b[1], _0xed3f77[3]),"happyCloseChannel: token transfer failure");
         }

         _0xa0131a--;

         emit DidLCClose(_0x356be4, _0xbc2cef, _0xed3f77[0], _0xed3f77[1], _0xed3f77[2], _0xed3f77[3]);
     }

     // Byzantine functions

     function _0x615e09(
         bytes32 _0x356be4,
         uint256[6] _0xf6b299, // [sequence, numOpenVc, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI]
         bytes32 _0xc78abd,
         string _0xbc734f,
         string _0x1a2b43
     )
         public
     {
         Channel storage _0x5779cc = Channels[_0x356be4];
         require(_0x5779cc._0x16ff5d);
         require(_0x5779cc._0xf38ac6 < _0xf6b299[0]); // do same as vc sequence check
         require(_0x5779cc._0x9d66dc[0] + _0x5779cc._0x9d66dc[1] >= _0xf6b299[2] + _0xf6b299[3]);
         require(_0x5779cc._0xab08c0[0] + _0x5779cc._0xab08c0[1] >= _0xf6b299[4] + _0xf6b299[5]);

         if(_0x5779cc._0xf4e517 == true) {
             require(_0x5779cc._0x5ed680 > _0xe09844);
         }

         bytes32 _0x56dd31 = _0x46f92f(
             abi._0xba3392(
                 _0x356be4,
                 false,
                 _0xf6b299[0],
                 _0xf6b299[1],
                 _0xc78abd,
                 _0x5779cc._0x61b15b[0],
                 _0x5779cc._0x61b15b[1],
                 _0xf6b299[2],
                 _0xf6b299[3],
                 _0xf6b299[4],
                 _0xf6b299[5]
             )
         );

         require(_0x5779cc._0x61b15b[0] == ECTools._0x8c5fd8(_0x56dd31, _0xbc734f));
         require(_0x5779cc._0x61b15b[1] == ECTools._0x8c5fd8(_0x56dd31, _0x1a2b43));

         // update LC state
         _0x5779cc._0xf38ac6 = _0xf6b299[0];
         _0x5779cc._0x9fe1f8 = _0xf6b299[1];
         _0x5779cc._0x9d66dc[0] = _0xf6b299[2];
         _0x5779cc._0x9d66dc[1] = _0xf6b299[3];
         _0x5779cc._0xab08c0[0] = _0xf6b299[4];
         _0x5779cc._0xab08c0[1] = _0xf6b299[5];
         _0x5779cc.VCrootHash = _0xc78abd;
         _0x5779cc._0xf4e517 = true;
         _0x5779cc._0x5ed680 = _0xe09844 + _0x5779cc._0xccd1b0;

         // make settlement flag

         emit DidLCUpdateState (
             _0x356be4,
             _0xf6b299[0],
             _0xf6b299[1],
             _0xf6b299[2],
             _0xf6b299[3],
             _0xf6b299[4],
             _0xf6b299[5],
             _0xc78abd,
             _0x5779cc._0x5ed680
         );
     }

     // supply initial state of VC to "prime" the force push game
     function _0xd57cc7(
         bytes32 _0x356be4,
         bytes32 _0x5b5159,
         bytes _0xc9d36c,
         address _0x2bd707,
         address _0x56a897,
         uint256[2] _0x5cea06,
         uint256[4] _0xed3f77, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
         string _0x6dd9b1
     )
         public
     {
         require(Channels[_0x356be4]._0x16ff5d, "LC is closed.");
         // sub-channel must be open
         require(!_0xf3dbcf[_0x5b5159]._0x1c1905, "VC is closed.");
         // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
         require(Channels[_0x356be4]._0x5ed680 < _0xe09844, "LC timeout not over.");
         // prevent rentry of initializing vc state
         require(_0xf3dbcf[_0x5b5159]._0x09f372 == 0);
         // partyB is now Ingrid
         bytes32 _0x5b86b0 = _0x46f92f(
             abi._0xba3392(_0x5b5159, uint256(0), _0x2bd707, _0x56a897, _0x5cea06[0], _0x5cea06[1], _0xed3f77[0], _0xed3f77[1], _0xed3f77[2], _0xed3f77[3])
         );

         // Make sure Alice has signed initial vc state (A/B in oldState)
         require(_0x2bd707 == ECTools._0x8c5fd8(_0x5b86b0, _0x6dd9b1));

         // Check the oldState is in the root hash
         require(_0xd81682(_0x5b86b0, _0xc9d36c, Channels[_0x356be4].VCrootHash) == true);

         _0xf3dbcf[_0x5b5159]._0xd58a9f = _0x2bd707; // VC participant A
         _0xf3dbcf[_0x5b5159]._0xb95393 = _0x56a897; // VC participant B
         _0xf3dbcf[_0x5b5159]._0xf38ac6 = uint256(0);
         _0xf3dbcf[_0x5b5159]._0x9d66dc[0] = _0xed3f77[0];
         _0xf3dbcf[_0x5b5159]._0x9d66dc[1] = _0xed3f77[1];
         _0xf3dbcf[_0x5b5159]._0xab08c0[0] = _0xed3f77[2];
         _0xf3dbcf[_0x5b5159]._0xab08c0[1] = _0xed3f77[3];
         _0xf3dbcf[_0x5b5159]._0xf2dd38 = _0x5cea06;
         _0xf3dbcf[_0x5b5159]._0x09f372 = _0xe09844 + Channels[_0x356be4]._0xccd1b0;
         _0xf3dbcf[_0x5b5159]._0x0cf94d = true;

         emit DidVCInit(_0x356be4, _0x5b5159, _0xc9d36c, uint256(0), _0x2bd707, _0x56a897, _0xed3f77[0], _0xed3f77[1]);
     }

     //TODO: verify state transition since the hub did not agree to this state
     // make sure the A/B balances are not beyond ingrids bonds
     // Params: vc init state, vc final balance, vcID
     function _0xdb41a1(
         bytes32 _0x356be4,
         bytes32 _0x5b5159,
         uint256 _0x305e0d,
         address _0x2bd707,
         address _0x56a897,
         uint256[4] _0x73248b, // [ethupdateBalA, ethupdateBalB, tokenupdateBalA, tokenupdateBalB]
         string _0x6dd9b1
     )
         public
     {
         require(Channels[_0x356be4]._0x16ff5d, "LC is closed.");
         // sub-channel must be open
         require(!_0xf3dbcf[_0x5b5159]._0x1c1905, "VC is closed.");
         require(_0xf3dbcf[_0x5b5159]._0xf38ac6 < _0x305e0d, "VC sequence is higher than update sequence.");
         require(
             _0xf3dbcf[_0x5b5159]._0x9d66dc[1] < _0x73248b[1] && _0xf3dbcf[_0x5b5159]._0xab08c0[1] < _0x73248b[3],
             "State updates may only increase recipient balance."
         );
         require(
             _0xf3dbcf[_0x5b5159]._0xf2dd38[0] == _0x73248b[0] + _0x73248b[1] &&
             _0xf3dbcf[_0x5b5159]._0xf2dd38[1] == _0x73248b[2] + _0x73248b[3],
             "Incorrect balances for bonded amount");
         // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
         // virtualChannels[_vcID].updateVCtimeout should be 0 on uninitialized vc state, and this should
         // fail if initVC() isn't called first
         // require(Channels[_lcID].updateLCtimeout < now && now < virtualChannels[_vcID].updateVCtimeout);
         require(Channels[_0x356be4]._0x5ed680 < _0xe09844); // for testing!

         bytes32 _0x790ebc = _0x46f92f(
             abi._0xba3392(
                 _0x5b5159,
                 _0x305e0d,
                 _0x2bd707,
                 _0x56a897,
                 _0xf3dbcf[_0x5b5159]._0xf2dd38[0],
                 _0xf3dbcf[_0x5b5159]._0xf2dd38[1],
                 _0x73248b[0],
                 _0x73248b[1],
                 _0x73248b[2],
                 _0x73248b[3]
             )
         );

         // Make sure Alice has signed a higher sequence new state
         require(_0xf3dbcf[_0x5b5159]._0xd58a9f == ECTools._0x8c5fd8(_0x790ebc, _0x6dd9b1));

         // store VC data
         // we may want to record who is initiating on-chain settles
         _0xf3dbcf[_0x5b5159]._0x01d008 = msg.sender;
         _0xf3dbcf[_0x5b5159]._0xf38ac6 = _0x305e0d;

         // channel state
         _0xf3dbcf[_0x5b5159]._0x9d66dc[0] = _0x73248b[0];
         _0xf3dbcf[_0x5b5159]._0x9d66dc[1] = _0x73248b[1];
         _0xf3dbcf[_0x5b5159]._0xab08c0[0] = _0x73248b[2];
         _0xf3dbcf[_0x5b5159]._0xab08c0[1] = _0x73248b[3];

         _0xf3dbcf[_0x5b5159]._0x09f372 = _0xe09844 + Channels[_0x356be4]._0xccd1b0;

         emit DidVCSettle(_0x356be4, _0x5b5159, _0x305e0d, _0x73248b[0], _0x73248b[1], msg.sender, _0xf3dbcf[_0x5b5159]._0x09f372);
     }

     function _0x69222a(bytes32 _0x356be4, bytes32 _0x5b5159) public {
         // require(updateLCtimeout > now)
         require(Channels[_0x356be4]._0x16ff5d, "LC is closed.");
         require(_0xf3dbcf[_0x5b5159]._0x0cf94d, "VC is not in settlement state.");
         require(_0xf3dbcf[_0x5b5159]._0x09f372 < _0xe09844, "Update vc timeout has not elapsed.");
         require(!_0xf3dbcf[_0x5b5159]._0x1c1905, "VC is already closed");
         // reduce the number of open virtual channels stored on LC
         Channels[_0x356be4]._0x9fe1f8--;
         // close vc flags
         _0xf3dbcf[_0x5b5159]._0x1c1905 = true;
         // re-introduce the balances back into the LC state from the settled VC
         // decide if this lc is alice or bob in the vc
         if(_0xf3dbcf[_0x5b5159]._0xd58a9f == Channels[_0x356be4]._0x61b15b[0]) {
             Channels[_0x356be4]._0x9d66dc[0] += _0xf3dbcf[_0x5b5159]._0x9d66dc[0];
             Channels[_0x356be4]._0x9d66dc[1] += _0xf3dbcf[_0x5b5159]._0x9d66dc[1];

             Channels[_0x356be4]._0xab08c0[0] += _0xf3dbcf[_0x5b5159]._0xab08c0[0];
             Channels[_0x356be4]._0xab08c0[1] += _0xf3dbcf[_0x5b5159]._0xab08c0[1];
         } else if (_0xf3dbcf[_0x5b5159]._0xb95393 == Channels[_0x356be4]._0x61b15b[0]) {
             Channels[_0x356be4]._0x9d66dc[0] += _0xf3dbcf[_0x5b5159]._0x9d66dc[1];
             Channels[_0x356be4]._0x9d66dc[1] += _0xf3dbcf[_0x5b5159]._0x9d66dc[0];

             Channels[_0x356be4]._0xab08c0[0] += _0xf3dbcf[_0x5b5159]._0xab08c0[1];
             Channels[_0x356be4]._0xab08c0[1] += _0xf3dbcf[_0x5b5159]._0xab08c0[0];
         }

         emit DidVCClose(_0x356be4, _0x5b5159, _0xf3dbcf[_0x5b5159]._0xab08c0[0], _0xf3dbcf[_0x5b5159]._0xab08c0[1]);
     }

     // todo: allow ethier lc.end-user to nullify the settled LC state and return to off-chain
     function _0x7ab184(bytes32 _0x356be4) public {
         Channel storage _0x5779cc = Channels[_0x356be4];

         // check settlement flag
         require(_0x5779cc._0x16ff5d, "Channel is not open");
         require(_0x5779cc._0xf4e517 == true);
         require(_0x5779cc._0x9fe1f8 == 0);
         require(_0x5779cc._0x5ed680 < _0xe09844, "LC timeout over.");

         // if off chain state update didnt reblance deposits, just return to deposit owner
         uint256 _0x4d78c0 = _0x5779cc._0xee9f70[0] + _0x5779cc._0x9d66dc[2] + _0x5779cc._0x9d66dc[3];
         uint256 _0x03ba76 = _0x5779cc._0xee9f70[1] + _0x5779cc._0xab08c0[2] + _0x5779cc._0xab08c0[3];

         uint256 _0x1fbc49 = _0x5779cc._0x9d66dc[0] + _0x5779cc._0x9d66dc[1];
         uint256 _0xbdac95 = _0x5779cc._0xab08c0[0] + _0x5779cc._0xab08c0[1];

         if(_0x1fbc49 < _0x4d78c0) {
             _0x5779cc._0x9d66dc[0]+=_0x5779cc._0x9d66dc[2];
             _0x5779cc._0x9d66dc[1]+=_0x5779cc._0x9d66dc[3];
         } else {
             require(_0x1fbc49 == _0x4d78c0);
         }

         if(_0xbdac95 < _0x03ba76) {
             _0x5779cc._0xab08c0[0]+=_0x5779cc._0xab08c0[2];
             _0x5779cc._0xab08c0[1]+=_0x5779cc._0xab08c0[3];
         } else {
             require(_0xbdac95 == _0x03ba76);
         }

         uint256 _0x66d2bc = _0x5779cc._0x9d66dc[0];
         uint256 _0xdd9c8b = _0x5779cc._0x9d66dc[1];
         uint256 _0x3170fa = _0x5779cc._0xab08c0[0];
         uint256 _0xa28c8a = _0x5779cc._0xab08c0[1];

         _0x5779cc._0x9d66dc[0] = 0;
         _0x5779cc._0x9d66dc[1] = 0;
         _0x5779cc._0xab08c0[0] = 0;
         _0x5779cc._0xab08c0[1] = 0;

         if(_0x66d2bc != 0 || _0xdd9c8b != 0) {
             _0x5779cc._0x61b15b[0].transfer(_0x66d2bc);
             _0x5779cc._0x61b15b[1].transfer(_0xdd9c8b);
         }

         if(_0x3170fa != 0 || _0xa28c8a != 0) {
             require(
                 _0x5779cc._0x06be49.transfer(_0x5779cc._0x61b15b[0], _0x3170fa),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 _0x5779cc._0x06be49.transfer(_0x5779cc._0x61b15b[1], _0xa28c8a),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         _0x5779cc._0x16ff5d = false;
         _0xa0131a--;

         emit DidLCClose(_0x356be4, _0x5779cc._0xf38ac6, _0x66d2bc, _0xdd9c8b, _0x3170fa, _0xa28c8a);
     }

     function _0xd81682(bytes32 _0xbf2ade, bytes _0xc9d36c, bytes32 _0x16404a) internal pure returns (bool) {
         bytes32 _0x654891 = _0xbf2ade;
         bytes32 _0x872ec0;

         for (uint256 i = 64; i <= _0xc9d36c.length; i += 32) {
             assembly { _0x872ec0 := mload(add(_0xc9d36c, i)) }

             if (_0x654891 < _0x872ec0) {
                 _0x654891 = _0x46f92f(abi._0xba3392(_0x654891, _0x872ec0));
             } else {
                 _0x654891 = _0x46f92f(abi._0xba3392(_0x872ec0, _0x654891));
             }
         }

         return _0x654891 == _0x16404a;
     }

     //Struct Getters
     function _0x852a8e(bytes32 _0x56f453) public view returns (
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
         Channel memory _0x5779cc = Channels[_0x56f453];
         return (
             _0x5779cc._0x61b15b,
             _0x5779cc._0x9d66dc,
             _0x5779cc._0xab08c0,
             _0x5779cc._0xee9f70,
             _0x5779cc._0xf38ac6,
             _0x5779cc._0xccd1b0,
             _0x5779cc.VCrootHash,
             _0x5779cc.LCopenTimeout,
             _0x5779cc._0x5ed680,
             _0x5779cc._0x16ff5d,
             _0x5779cc._0xf4e517,
             _0x5779cc._0x9fe1f8
         );
     }

     function _0xf6d6f7(bytes32 _0x56f453) public view returns(
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
         VirtualChannel memory _0x24cb0b = _0xf3dbcf[_0x56f453];
         return(
             _0x24cb0b._0x1c1905,
             _0x24cb0b._0x0cf94d,
             _0x24cb0b._0xf38ac6,
             _0x24cb0b._0x01d008,
             _0x24cb0b._0x09f372,
             _0x24cb0b._0xd58a9f,
             _0x24cb0b._0xb95393,
             _0x24cb0b._0x4868cf,
             _0x24cb0b._0x9d66dc,
             _0x24cb0b._0xab08c0,
             _0x24cb0b._0xf2dd38
         );
     }
 }
