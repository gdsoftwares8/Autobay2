pragma solidity 0.4.24;


import "./MintingERC20.sol";

import "./ICO.sol";

import "./SafeMath.sol";





contract Autobay is MintingERC20 {



    using SafeMath for uint256;



    ICO public ico;



    address public fundAddress;

    address public bountyAddress;

    address public allowedAddress;



    bool public transferFrozen = true;



   constructor(

        address _fundAddress,

        address _bountyAddress,

        bool _locked

    )

       MintingERC20(0, maxSupply, "Autobay", 18, "ABX", false, _locked) public

    {

        standard = "ABX 0.1";



        maxSupply = uint(945000000).mul(uint(10) ** decimals);



        initialAllocation(_fundAddress, _bountyAddress);

    }



    function setICO(address _ico) public onlyOwner {

        require(_ico != address(0));

        ico = ICO(_ico);

    }



    function setAllowedAddress(address _allowedAddress) public onlyOwner {

        require(_allowedAddress != address(0));

        allowedAddress = _allowedAddress;

    }



    function setLocked(bool _locked) public onlyOwner {

        locked = _locked;

    }



    function freezing(bool _transferFrozen) public onlyOwner {

        if (address(ico) != address(0) && ico.isICOFinished()) {

            transferFrozen = _transferFrozen;

        }

    }



    function mint(address _addr, uint256 _amount) public onlyMinters returns (uint256) {

        if (msg.sender == owner) {

            require(address(ico) != address(0));

            if (ico.isICOFinished() || _addr == allowedAddress) {

                return super.mint(_addr, _amount);

            }

            return uint256(0);

        }

        return super.mint(_addr, _amount);

    }


      function transferAllowed(address _address) public view returns (bool) {

        if (_address == bountyAddress) {

            return true;
        }

        return !transferFrozen;
    }


    function transfer(address _to, uint _value) public returns (bool) {

        require(transferAllowed(msg.sender));

        return super.transfer(_to, _value);

    }



    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {

        require(transferAllowed(_from));

        return super.transferFrom(_from, _to, _value);

    }



    function initialAllocation(

        address _fundAddress,

        address _bountyAddress

    ) internal {

        require(_fundAddress != address(0) && _bountyAddress != address(0));



        fundAddress = _fundAddress;

        bountyAddress = _bountyAddress;


	uint256 amount = uint(3969000005).mul(uint(10) ** uint(decimals - 1));

        bool status = super.mint(_fundAddress, amount) == amount;


	if (status) {

            amount = uint(28350000).mul(uint(10) ** decimals);

            status = super.mint(bountyAddress, amount) == amount;
        }


        require(status == true);

    }



}