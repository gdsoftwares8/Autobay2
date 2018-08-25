pragma solidity 0.4.24;





import "./AutobayERC20.sol";





/*

This contract manages the minters and the modifier to allow mint to happen only if called by minters

This contract contains basic minting functionality though

*/

contract MintingERC20 is AutobayERC20 {



    //Variables

    mapping (address => bool) public minters;

    event Transfer(
        address indexed _form,
        address indexed _to,
        uint256 _value
        );


    uint256 public maxSupply;

  

    //Modifiers

    modifier onlyMinters () {

        require(true == minters[msg.sender]);

        _;

    }



    constructor(

        uint256 _initialSupply,

        uint256 _maxSupply,

        string _tokenName,

        uint8 _decimals,

        string _symbol,

        bool _transferAllSupplyToOwner,

        bool _locked
) 

     AutobayERC20(_initialSupply, _tokenName, _decimals, _symbol, _transferAllSupplyToOwner, _locked) public

    {

        standard = "MintingERC20 0.1";

        minters[msg.sender] = true;

        maxSupply = _maxSupply;

    }



    function addMinter(address _newMinter) public onlyOwner {

        minters[_newMinter] = true;

    }



    function removeMinter(address _minter) public onlyOwner {

        minters[_minter] = false;

    }



    function mint(address _addr, uint256 _amount) public onlyMinters returns (uint256) {

        if (true == locked) {

            return uint256(0);

        }



        if (_amount == uint256(0)) {

            return uint256(0);

        }



        if (totalSupply.add(_amount) > maxSupply) {

            return uint256(0);

        }



        totalSupply = totalSupply.add(_amount);

        balances[_addr] = balances[_addr].add(_amount);

        emit Transfer(address(0), _addr, _amount);



        return _amount;

    }

}