import { getComponentValue } from "@latticexyz/recs";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";
import { singletonEntity } from "@latticexyz/store-sync/recs";

import * as snarkjs from 'snarkjs';

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { worldContract, waitForTransaction }: SetupNetworkResult,
  { PlayerPosition, CoinPosition }: ClientComponents,
) {
  const spawn = async (x: number, y: number) => {
    const tx = await worldContract.write.app__spawn([x, y]);
    await waitForTransaction(tx);
    return getComponentValue(PlayerPosition, singletonEntity);
  };

  const move = async (direction: number) => {
    const tx = await worldContract.write.app__move([direction]);
    await waitForTransaction(tx);
    return getComponentValue(PlayerPosition,  singletonEntity);
  }

  const generateCoins = async (direction: number) => {
    const tx = await worldContract.write.app__generateCoins();
    await waitForTransaction(tx);
    return getComponentValue(PlayerPosition,  singletonEntity);
  }

  const detonateBomb = async (x: number, y: number, playerAddress: any) => {
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    {
        aX: 1,
        aY: 1,
        bX: 2,
        bY: 2,
        cX: 2,
        cY: 3,
        guessX: x,
        guessY: y
    }, "src/zk_artifacts/proveWrong.wasm", "src/zk_artifacts/proveWrong_final.zkey");

    const vkey = await fetch("src/zk_artifacts/verification_key.json").then( function(res) {
        return res.json();
    });

    const res = await snarkjs.groth16.verify(vkey, publicSignals, proof);

    let pA = proof.pi_a
    pA.pop()
    let pB = proof.pi_b
    pB.pop()
    let pC = proof.pi_c
    pC.pop()

    if(publicSignals[1] == "1")
    {
      console.log("Bomb!!");
      const tx = await worldContract.write.app__detonateBomb([pA, pB, pC, publicSignals, playerAddress]);
      await waitForTransaction(tx);
      return getComponentValue(PlayerPosition,  singletonEntity);
    }
  }
  return {
    spawn, move, generateCoins, detonateBomb
  };
}
