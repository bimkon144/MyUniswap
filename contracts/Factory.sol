//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import './Pair.sol';
import '../interface/RegistryInterface.sol';
import '../interface/FactoryInterface.sol';
import '../interface/EventsInterface.sol';
import "@openzeppelin/contracts/utils/Address.sol";

contract Factory is Ownable, FactoryInterface, EventsInterface  {

    address public router;
    RegistryInterface public registry;
    address public feeContract;
    using Address for address;


    function setRouter(address _router) external override onlyOwner {
        // require(_router != address(0) && _router.isContract(), "Invalid address or its not contract");
        router = _router;
        emit Router(_router, address(this));
    }
    function setRegistry(address _registry) external override onlyOwner {
        // require(_registry != address(0) && _registry.isContract(), "Invalid address or its not contract");
        registry = RegistryInterface(_registry);
        emit Registry(_registry, address(this));
    }
    function setFeeContract(address _feeContract) external override onlyOwner {
        // require(_feeContract != address(0) && _feeContract.isContract(), "Invalid address or its not contract");
        feeContract = _feeContract;
        emit FeeContract(_feeContract, address(this));
    }

    function createPair(address tokenA, address tokenB) external override returns (address){
        // require(tokenA != tokenB, ' IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        // require(token0 != address(0), 'ZERO_ADDRESS');
        require(registry.getAddressOfPair(token0, token1) == address(0), ' PAIR_EXISTS');
        Pair newPair = new Pair("PoolToken", "PLT", router, feeContract, token0, token1);
        newPair.transferOwnership(owner());
        address addressOfPair = address(newPair);
        registry.setPair(token0, token1, addressOfPair);
        emit NewPair(token0, token1, addressOfPair);
        return addressOfPair;
    }

}