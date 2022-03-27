//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import '../interface/PairInterface.sol';
import "hardhat/console.sol";
import '../interface/FeeInterface.sol';
import '../interface/EventsInterface.sol';


 contract  Pair is ERC20, ReentrancyGuard, Ownable, PairInterface, EventsInterface {
    address public router;
    address public factory;
    address public token0;
    address public token1;
    FeeInterface public feeContract;
    using SafeERC20 for IERC20;
    using Address for address;

    constructor(
        string memory _name,
        string memory _symbol,
        address  _router,
        address _feeContract,
        address  _token0,
        address  _token1

    ) ERC20(_name, _symbol) {
        router = _router;
        token0 = _token0;
        token1 = _token1;
        feeContract = FeeInterface(_feeContract);
        initialize(_token0,_token1);
        factory = msg.sender;
    }


    function setRouter(address _router) external override onlyOwner {
        require(_router != address(0) && _router.isContract(), "Invalid address or its not contract");
        router = _router;
        emit Router(_router, address(this));
    }

    function setFeeContract(address _feeContract) external  onlyOwner {
        // require(_feeContract != address(0) && _feeContract.isContract(), "Invalid address or its not contract");
        feeContract = FeeInterface(_feeContract);
        emit FeeContract(_feeContract, address(this));
    }

    modifier onlyRouter() {
        require(router == _msgSender(), " caller is not the Router");
        _;
    }


    function initialize(address _token0, address _token1) internal {
        // require(_token0 != address(0) && _token1 != address(0), "Invalid address");
        // require(_token0.isContract() && _token1.isContract(), "its not contracts");
        token0 = _token0;
        token1 = _token1;
        emit Initializes(_token0, _token1, address(this));
    }

    function addLiquidity (address _token0, address _token1, uint _count0, uint _count1, address _recipient) external override nonReentrant returns (uint256 liquidity){
        if (getReserveOfToken(_token0) == 0 && getReserveOfToken(_token1) == 0) { 
            IERC20(_token0).safeTransferFrom(_recipient, address(this), _count0);
            IERC20(_token1).safeTransferFrom(_recipient, address(this), _count1);
            liquidity = _count0 + _count1;
            emit Liquidity(_recipient, _token0, _token1, liquidity);
            _mint(_recipient, liquidity);
            return  liquidity;

        } else {
            uint256 token0Reserve = getReserveToken0();
            uint256 token1Reserve = getReserveToken1();
            uint256 token1Amount = (_count0 * token1Reserve) /  token0Reserve;
            uint256 token0Amount = (_count1 * token0Reserve) /  token1Reserve;
            if (_count1 == token1Amount) {
                _addLiquidity(_token0, _token1, _count0, _count1, _recipient, liquidity);
            }
            if (_count1 > token1Amount) {
                _count1 = token1Amount;
                _addLiquidity(_token0, _token1, _count0, _count1, _recipient, liquidity);
                
            }
            if (_count1 < token1Amount) {
                _count0 = token0Amount;                
                _addLiquidity(_token0, _token1, _count0, _count1, _recipient, liquidity);
            }
        }
    }

    function _addLiquidity(address _token0, address _token1, uint _count0, uint _count1, address _recipient, uint liquidity) private {
        IERC20(_token0).safeTransferFrom(_recipient, address(this), _count0);
        IERC20(_token1).safeTransferFrom(_recipient, address(this), _count1);
        liquidity = (_count0 * totalSupply()) / getReserveOfToken(_token0);
        emit Liquidity(_recipient, token0, _token1, liquidity);
        _mint(_recipient, liquidity);
    }

    function removeLiquidity(uint256 _amount, address _token0, address _token1, address _recipient)  public override nonReentrant returns (uint256, uint256)  {
        require(_amount > 0, "invalid amount of LP tokens");
        uint256 token0Amount = (getReserveOfToken(_token0) * _amount) / totalSupply();
        uint256 token1Amount = (getReserveOfToken(_token1) * _amount) / totalSupply();
        _burn(_recipient, _amount);
        IERC20(token0).safeTransfer(_recipient, token0Amount);
        IERC20(token1).safeTransfer(_recipient, token1Amount); 
        emit RemovedLiquidity(_recipient, address(this),_amount,_token0, _token1, token0Amount, token1Amount);      
        return (token0Amount, token1Amount);
    }

    function getReserveToken0() public override view returns (uint256) {
        return IERC20(token0).balanceOf(address(this));
    }

    function getReserveToken1() public override view returns (uint256) {
        return IERC20(token1).balanceOf(address(this));
    }

    function getReserveOfToken(address _token) public  view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }
     
     function swapIn(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _minAmountOut,
        address _recipient
    ) external  override onlyRouter nonReentrant returns (uint256) {
        uint256 token0Reserve = getReserveOfToken(_tokenIn);
        uint256 token1Reserve = getReserveOfToken(_tokenOut);
        address protocolPerformanceFeeRecipient = feeContract.protocolPerformanceFeeRecipient();
        uint tokenAmooutOutWithFee;
        uint amountOfProtocolFree;
        (tokenAmooutOutWithFee, amountOfProtocolFree) = getAmountOut(
            _amountIn,
            token0Reserve,
            token1Reserve
        );
        require(tokenAmooutOutWithFee >= _minAmountOut);
        IERC20(_tokenIn).safeTransferFrom(
            _recipient,
            address(this),
            _amountIn
        );
        
        // console.log('AmountOfProtocolFree', AmountOfProtocolFree, '_amountIn', amountInn);
        // console.log('protocolPerformanceFee', protocolPerformanceFee, 'feeDecimals', feeDecimals);
        IERC20(_tokenIn).safeTransfer(protocolPerformanceFeeRecipient, amountOfProtocolFree);
        IERC20(_tokenOut).safeTransfer(_recipient, tokenAmooutOutWithFee);
        emit SwapedIn(_tokenIn, _amountIn, _tokenOut, tokenAmooutOutWithFee, _recipient);
        return tokenAmooutOutWithFee;
    }

    function swapOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOut,
        uint256 _maxAmountIn,
        address _recipient
    ) external  override onlyRouter nonReentrant returns (uint256) {
        uint256 token0Reserve = getReserveOfToken(_tokenIn);
        uint256 token1Reserve = getReserveOfToken(_tokenOut);
        address protocolPerformanceFeeRecipient = feeContract.protocolPerformanceFeeRecipient();
        uint tokenAmooutInWithFee;
        uint amountOfProtocolFree;
        (tokenAmooutInWithFee, amountOfProtocolFree) = getAmountIn(
            _amountOut,
            token0Reserve,
            token1Reserve
        );
        require(_maxAmountIn >= tokenAmooutInWithFee, "invalid amount of maxAmountIn");
        IERC20(_tokenIn).safeTransferFrom(
            _recipient,
            address(this),
            tokenAmooutInWithFee
        );
 
        IERC20(token0).safeTransfer(protocolPerformanceFeeRecipient, amountOfProtocolFree);
        IERC20(_tokenOut).safeTransfer(_recipient, _amountOut);
        emit SwapedOut(_tokenIn, tokenAmooutInWithFee, _tokenOut, _amountOut, _recipient);
        return tokenAmooutInWithFee;
    }

    function getAmountOut(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public  returns (uint256, uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        uint256 swapFee = feeContract.swapFee();
        uint256 protocolPerformanceFee = feeContract.protocolPerformanceFee();
        uint256 feeDecimals =feeContract.feeDecimals();
        uint amountInWithFee = inputAmount * (10**feeDecimals - swapFee - protocolPerformanceFee);
        uint numerator = amountInWithFee * outputReserve;
        uint denominator = ((inputReserve * 10**feeDecimals)+amountInWithFee);
        uint amountOfProtocolFree = inputAmount - ((inputAmount * (10**feeDecimals - protocolPerformanceFee)) / (10**feeDecimals));
        return ((numerator / denominator), amountOfProtocolFree);
    }

    function getAmountIn(
        uint256 outputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public  returns (uint256, uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        uint256 swapFee = feeContract.swapFee();
        uint256 protocolPerformanceFee = feeContract.protocolPerformanceFee();
        uint256 feeDecimals = feeContract.feeDecimals();
        uint numerator = (inputReserve * outputAmount * 10**feeDecimals);
        uint denominator = ((outputReserve - outputAmount) * (10**feeDecimals - swapFee - protocolPerformanceFee));
        uint256 amountOfProtocolFree =  outputAmount - ((outputAmount * (10**feeDecimals - protocolPerformanceFee) )/ (10**feeDecimals));
        return (((numerator / denominator) + 1), amountOfProtocolFree);
        
    }
}
