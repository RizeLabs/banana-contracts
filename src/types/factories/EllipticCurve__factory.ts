/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../common";
import type { EllipticCurve, EllipticCurveInterface } from "../EllipticCurve";

const _abi = [
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "x1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y1",
        type: "uint256",
      },
    ],
    name: "add",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "x2",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y2",
        type: "uint256",
      },
    ],
    name: "addAndReturnProjectivePoint",
    outputs: [
      {
        internalType: "uint256[3]",
        name: "P",
        type: "uint256[3]",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "z0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "x1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "z1",
        type: "uint256",
      },
    ],
    name: "addProj",
    outputs: [
      {
        internalType: "uint256",
        name: "x2",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y2",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "z2",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y",
        type: "uint256",
      },
    ],
    name: "isOnCurve",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
    ],
    name: "isZeroCurve",
    outputs: [
      {
        internalType: "bool",
        name: "isZero",
        type: "bool",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "scalar",
        type: "uint256",
      },
    ],
    name: "multipleGeneratorByScalar",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "exp",
        type: "uint256",
      },
    ],
    name: "multiplyPowerBase2",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "scalar",
        type: "uint256",
      },
    ],
    name: "multiplyScalar",
    outputs: [
      {
        internalType: "uint256",
        name: "x1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y1",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "z0",
        type: "uint256",
      },
    ],
    name: "toAffinePoint",
    outputs: [
      {
        internalType: "uint256",
        name: "x1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y1",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
    ],
    name: "toProjectivePoint",
    outputs: [
      {
        internalType: "uint256[3]",
        name: "P",
        type: "uint256[3]",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
    ],
    name: "twice",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "x0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "z0",
        type: "uint256",
      },
    ],
    name: "twiceProj",
    outputs: [
      {
        internalType: "uint256",
        name: "x1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y1",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "z1",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "message",
        type: "bytes32",
      },
      {
        internalType: "uint256[2]",
        name: "rs",
        type: "uint256[2]",
      },
      {
        internalType: "uint256[2]",
        name: "Q",
        type: "uint256[2]",
      },
    ],
    name: "validateSignature",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [],
    name: "zeroAffine",
    outputs: [
      {
        internalType: "uint256",
        name: "x",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [],
    name: "zeroProj",
    outputs: [
      {
        internalType: "uint256",
        name: "x",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "y",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "z",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
] as const;

const _bytecode =
  "0x608060405234801561001057600080fd5b5061154f806100206000396000f3fe608060405234801561001057600080fd5b50600436106100f55760003560e01c8063713eca2811610097578063c30cfa2d11610066578063c30cfa2d14610205578063c80edca414610218578063e022d77c1461022b578063f214aba01461023e57600080fd5b8063713eca28146101b757806372fb4a14146101d75780637ec8da8d146101ea57806384dfba46146101fd57600080fd5b80630b0dbcfa116100d35780630b0dbcfa1461015d57806314c6706014610170578063322b24aa14610191578063675ca043146101a457600080fd5b806304e960d7146100fa57806309d3ef31146101225780630afb4ddc1461014a575b600080fd5b61010d610108366004611305565b610251565b60405190151581526020015b60405180910390f35b610135610130366004611343565b610470565b60408051928352602083019190915201610119565b610135610158366004611365565b61049f565b61010d61016b366004611343565b6104f6565b60006001815b60408051938452602084019290925290820152606001610119565b61013561019f36600461137e565b610670565b6101356101b236600461137e565b6106c1565b6101ca6101c53660046113aa565b610747565b60405161011991906113dc565b6101356101e536600461137e565b610778565b6101ca6101f8366004611343565b610847565b600080610135565b61010d610213366004611343565b6108d6565b61017661022636600461137e565b6108fa565b6101356102393660046113aa565b610d05565b61017661024c36600461140d565b610d3a565b81516000901580610283575082517fffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc63255111155b8061029057506020830151155b1561029d57506000610469565b815160208301516102ae91906104f6565b6102ba57506000610469565b6000808080806102f188600160200201517fffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551610e99565b90506103617f6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2967f4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f57fffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551848d09610778565b885160208a01518b519398509195506103a1929091907fffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc63255190859009610778565b909450915060006103b486858786610747565b60408101519091506000036103d25760009650505050505050610469565b600061040582600260200201517fffffffff00000001000000000000000000000000ffffffffffffffffffffffff610e99565b90507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff808283098351098a5190915061045e7fffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc6325518361147f565b149750505050505050505b9392505050565b6000806000610481858560016108fa565b919650945090506104938585836106c1565b92509250509250929050565b6000806104ed7f6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c2967f4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f585610778565b91509150915091565b600082158061052457507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff83145b8061052d575081155b8061055757507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff82145b156105645750600061066a565b60007fffffffff00000001000000000000000000000000ffffffffffffffffffffffff838409905060007fffffffff00000001000000000000000000000000ffffffffffffffffffffffff857fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8788090990507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff807fffffffff00000001000000000000000000000000fffffffffffffffffffffffc8709820890507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff7f5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b820890501490505b92915050565b60008084846001835b868110156106a55761068c8484846108fa565b919550935091508061069d816114ba565b915050610679565b506106b18383836106c1565b945094505050505b935093915050565b60008060006106f0847fffffffff00000001000000000000000000000000ffffffffffffffffffffffff610e99565b90507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff81870992507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff818609915050935093915050565b61074f611250565b60008061075e87878787610d05565b909250905061076d8282610847565b979650505050505050565b60008082600003610790576000805b915091506106b9565b826001036107a25750839050826106b9565b826002036107b4576107878585610470565b508390508281816001806107c960028861147f565b6000036107d857600094508495505b600187901c96505b861561082c576107f18484846108fa565b9195509350915061080360028861147f565b60010361082057610818848484898986610d3a565b919750955090505b600187901c96506107e0565b6108378686836106c1565b9550955050505050935093915050565b61084f611250565b7fffffffff00000001000000000000000000000000ffffffffffffffffffffffff6001600008604082018190527fffffffff00000001000000000000000000000000ffffffffffffffffffffffff908409815260408101517fffffffff00000001000000000000000000000000ffffffffffffffffffffffff908309602082015292915050565b6000821580156108e4575081155b156108f15750600161066a565b50600092915050565b600080600080600080600061090f8a8a6108d6565b1561092857600060018196509650965050505050610cfc565b7fffffffff00000001000000000000000000000000ffffffffffffffffffffffff888a0992507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff6002840992507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8a840991507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff89830991507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff6002830991507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8a8b0999507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff60038b0993507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff88890997507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff7fffffffff00000001000000000000000000000000fffffffffffffffffffffffc890997507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff88850893507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff84850990507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8260020999507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8a7fffffffff00000001000000000000000000000000ffffffffffffffffffffffff03820890507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff817fffffffff00000001000000000000000000000000ffffffffffffffffffffffff03830899507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8a850999507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff838a0998507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff898a0998507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8960020998507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff897fffffffff00000001000000000000000000000000ffffffffffffffffffffffff038b0895507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff81840996507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff83840994507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8386099450505050505b93509350939050565b6000806000610d1a8787600188886001610d3a565b91985096509050610d2c8787836106c1565b925092505094509492505050565b6000806000806000806000610d4f8d8d6108d6565b15610d665789898996509650965050505050610e8d565b610d708a8a6108d6565b15610d87578c8c8c96509650965050505050610e8d565b7fffffffff00000001000000000000000000000000ffffffffffffffffffffffff888d0993507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8b8a0992507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff888e0991507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8b8b099050808203610e5157828403610e4757610e388d8d8d6108fa565b96509650965050505050610e8d565b6000600181610e38565b610e817fffffffff00000001000000000000000000000000ffffffffffffffffffffffff898d0983838688610f2d565b91985096509450505050505b96509650969350505050565b6000821580610ea757508183145b80610eb0575081155b15610ebd5750600061066a565b81831115610ed257610ecf828461147f565b92505b600060018385835b8115610f0957818381610eef57610eef611450565b949594048581029094039391928383029003919050610eda565b6000851215610f2157505050908301915061066a9050565b50929695505050505050565b6000808080808080807fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8a7fffffffff00000001000000000000000000000000ffffffffffffffffffffffff038a0890507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8b7fffffffff00000001000000000000000000000000ffffffffffffffffffffffff038d0894507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff85860993507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff81820991507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8d830991507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8c8c089a507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff848c099a507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8b7fffffffff00000001000000000000000000000000ffffffffffffffffffffffff03830891507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff82860997507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff85850992507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff848d099b507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff827fffffffff00000001000000000000000000000000ffffffffffffffffffffffff038d089b507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8c820990507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff838a0998507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff897fffffffff00000001000000000000000000000000ffffffffffffffffffffffff03820896507fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8d840995505050505050955095509592505050565b60405180606001604052806003906020820280368337509192915050565b600082601f83011261127f57600080fd5b6040516040810181811067ffffffffffffffff821117156112c9577f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b80604052508060408401858111156112e057600080fd5b845b818110156112fa5780358352602092830192016112e2565b509195945050505050565b600080600060a0848603121561131a57600080fd5b8335925061132b856020860161126e565b915061133a856060860161126e565b90509250925092565b6000806040838503121561135657600080fd5b50508035926020909101359150565b60006020828403121561137757600080fd5b5035919050565b60008060006060848603121561139357600080fd5b505081359360208301359350604090920135919050565b600080600080608085870312156113c057600080fd5b5050823594602084013594506040840135936060013592509050565b60608101818360005b60038110156114045781518352602092830192909101906001016113e5565b50505092915050565b60008060008060008060c0878903121561142657600080fd5b505084359660208601359650604086013595606081013595506080810135945060a0013592509050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601260045260246000fd5b6000826114b5577f4e487b7100000000000000000000000000000000000000000000000000000000600052601260045260246000fd5b500690565b60007fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8203611512577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b506001019056fea264697066735822122075b80edd5509b1e1f5a4e79b8ffa6643ff6068e374e751c6e4c5b6afff6999f864736f6c634300080f0033";

type EllipticCurveConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: EllipticCurveConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class EllipticCurve__factory extends ContractFactory {
  constructor(...args: EllipticCurveConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<EllipticCurve> {
    return super.deploy(overrides || {}) as Promise<EllipticCurve>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): EllipticCurve {
    return super.attach(address) as EllipticCurve;
  }
  override connect(signer: Signer): EllipticCurve__factory {
    return super.connect(signer) as EllipticCurve__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): EllipticCurveInterface {
    return new utils.Interface(_abi) as EllipticCurveInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): EllipticCurve {
    return new Contract(address, _abi, signerOrProvider) as EllipticCurve;
  }
}