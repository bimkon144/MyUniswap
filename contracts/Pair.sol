//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import '../lib/SafeMath.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '../interface/PairInterface.sol';
import "hardhat/console.sol";
import '../interface/FeeInterface.sol';


 contract  Pair is ERC20, ReentrancyGuard, Ownable, PairInterface {
    using SafeMath  for uint;
    address public router;
    address public factory;
    address public token0;
    address public token1;
    address public feeContract;

    constructor(
        string memory _name,
        string memory _symbol,
        address  _router,
        address _feeContract

    ) ERC20(_name, _symbol) {
        router = _router;
        feeContract = _feeContract;
        factory = msg.sender;
    }


    function setRouter(address _router) external override onlyOwner {
        router = _router;
    }

    function setFeeContract(address _feeContract) external  onlyOwner {
        feeContract = _feeContract;
    }

    modifier onlyRouter() {
        require(router == _msgSender(), " caller is not the Router");
        _;
    }


    function initialize(address _token0, address _token1) external override {
        require(msg.sender == factory, ' FORBIDDEN'); 
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity (address _token0, address _token1, uint _count0, uint _count1, address _recipient) external override returns (uint256 liquidity){
        if (getReserveOfToken(_token0) == 0 && getReserveOfToken(_token1) == 0) { 
            IERC20(_token0).transferFrom(_recipient, address(this), _count0);
            IERC20(_token1).transferFrom(_recipient, address(this), _count1);
            liquidity = _count0.add(_count1);
            _mint(_recipient, liquidity);
            return  liquidity;

        } else {
            uint256 token0Reserve = getReserveToken0();
            uint256 token1Reserve = getReserveToken1();
            uint256 token1Amount = (_count0 * token1Reserve) /  token0Reserve;
            require(_count1 >= token1Amount, "insufficient token1 amount");
            uint256 token0Amount = (_count1 * token0Reserve) /  token1Reserve;
            require(_count0 >= token0Amount, "insufficient token0 amount");
            IERC20(_token0).transferFrom(_recipient, address(this), _count0);
            IERC20(_token1).transferFrom(_recipient, address(this), _count1);
            liquidity = (_count0 * totalSupply()) / token0Reserve;
            _mint(_recipient, liquidity);
            return liquidity;
        }
    }

    function removeLiquidity(uint256 _amount, address _token0, address _token1, address _recipient)  public override nonReentrant returns (uint256, uint256)  {
        require(_amount > 0, "invalid amount of LP tokens");

        uint256 token0Amount = (getReserveOfToken(_token0) * _amount) / totalSupply();
        uint256 token1Amount = (getReserveOfToken(_token1) * _amount) / totalSupply();

        _burn(_recipient, _amount);
        IERC20(token0).transfer(_recipient, token0Amount);
        IERC20(token1).transfer(_recipient, token1Amount);

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
        uint256 swapFee = FeeInterface(feeContract).swapFee();
        uint256 protocolPerformanceFee = FeeInterface(feeContract).protocolPerformanceFee();
        address protocolPerformanceFeeRecipient = FeeInterface(feeContract).protocolPerformanceFeeRecipient();
        uint256 feeDecimals = FeeInterface(feeContract).feeDecimals();

        uint256 tokenAmooutOutWithFee = getAmountOut(
            _amountIn,
            token0Reserve,
            token1Reserve,
            swapFee,
            protocolPerformanceFee,
            feeDecimals
        );
        require(tokenAmooutOutWithFee >= _minAmountOut);
        IERC20(_tokenIn).transferFrom(
            _recipient,
            address(this),
            _amountIn
        );
        // uint256 AmountOfTokensWithProtocolFree =  _amountIn * protocolPerformanceFee / 10**feeDecimals;
        // IERC20(token0).transfer(protocolPerformanceFeeRecipient, AmountOfTokensWithProtocolFree);
        IERC20(_tokenOut).transfer(_recipient, tokenAmooutOutWithFee);
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
        uint256 swapFee = FeeInterface(feeContract).swapFee();
        uint256 protocolPerformanceFee = FeeInterface(feeContract).protocolPerformanceFee();
        address protocolPerformanceFeeRecipient = FeeInterface(feeContract).protocolPerformanceFeeRecipient();
        uint256 feeDecimals = FeeInterface(feeContract).feeDecimals();

        uint256 tokenAmooutInWithFee = getAmountIn(
            _amountOut,
            token0Reserve,
            token1Reserve,
            swapFee,
            protocolPerformanceFee,
            feeDecimals
        );
        require(_maxAmountIn >= tokenAmooutInWithFee, "invalid amount of maxAmountIn");
        IERC20(_tokenIn).transferFrom(
            _recipient,
            address(this),
            tokenAmooutInWithFee
        );
        // uint256 AmountOfTokensWithProtocolFree =  _amountOut * protocolPerformanceFee / 10**feeDecimals;
        // IERC20(token0).transfer(protocolPerformanceFeeRecipient, AmountOfTokensWithProtocolFree);
        IERC20(_tokenOut).transfer(_recipient, _amountOut);
        return tokenAmooutInWithFee;
    }

    function getAmountOut(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve,
        uint256 swapFee,
        uint256 protocolPerformanceFee,
        uint256 feeDecimals

    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        uint amountInWithFee = inputAmount * (10**feeDecimals - swapFee);
        uint numerator = amountInWithFee * outputReserve;
        uint denominator = ((inputReserve * 10**feeDecimals)+amountInWithFee);
        return numerator / denominator;
    }

    function getAmountIn(
        uint256 outputAmount,
        uint256 inputReserve,
        uint256 outputReserve,  
        uint256 swapFee,
        uint256 protocolPerformanceFee,
        uint256 feeDecimals

    ) public  pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        uint numerator = (inputReserve * outputAmount * 10**feeDecimals);
        uint denominator = ((outputReserve - outputAmount) * (10**feeDecimals - swapFee ));
        return (numerator / denominator) + 1;
        
    }
}
