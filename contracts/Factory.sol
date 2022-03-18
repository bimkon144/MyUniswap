//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import './Pair.sol';
import '../interface/RegistryInterface.sol';
import '../interface/FactoryInterface.sol';

contract Factory is Ownable, FactoryInterface {

    address public router;
    address public registry;
    address public feeContract;

    function setRouter(address _router) external override onlyOwner {
        router = _router;
    }
    function setRegistry(address _registry) external override onlyOwner {
        registry = _registry;
    }
    function setFeeContract(address _feeContract) external override onlyOwner {
        feeContract = _feeContract;
    }

    function createPair(address tokenA, address tokenB) external override returns (address){
        require(tokenA != tokenB, ' IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZERO_ADDRESS');
        require(RegistryInterface(registry).getAddressOfPair(token0, token1) == address(0), ' PAIR_EXISTS');
        Pair newPair = new Pair("PoolToken", "PLT", router, feeContract);
        newPair.initialize(token0, token1);
        newPair.transferOwnership(owner());
        address addressOfPair = address(newPair);
        RegistryInterface(registry).setPair(token0, token1, addressOfPair);
        return addressOfPair;
    }

}