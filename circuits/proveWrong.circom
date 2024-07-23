pragma circom 2.0.0;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/comparators.circom";

template commitmentHasher() {
    signal input aX;
    signal input aY;
    signal input bX;
    signal input bY;
    signal input cX;
    signal input cY;
    signal output commitment;
    component poseidonComponent;
    poseidonComponent = Poseidon(6);
    poseidonComponent.inputs[0] <== aX;
    poseidonComponent.inputs[1] <== aY;
    poseidonComponent.inputs[2] <== bX;
    poseidonComponent.inputs[3] <== bY;
    poseidonComponent.inputs[4] <== cX;
    poseidonComponent.inputs[5] <== cY;
    commitment <== poseidonComponent.out;
}

template proveWrong() {
    signal input aX;
    signal input aY;
    signal input bX;
    signal input bY;
    signal input cX;
    signal input cY;
    signal input guessX;
    signal input guessY;
    signal output commitment;
    signal output result;

    component commitmentHasherComponent;
    commitmentHasherComponent = commitmentHasher();
    commitmentHasherComponent.aX <== aX;
    commitmentHasherComponent.aY <== aY;
    commitmentHasherComponent.bX <== bX;
    commitmentHasherComponent.bY <== bY;
    commitmentHasherComponent.cX <== cX;
    commitmentHasherComponent.cY <== cY;
    commitment <== commitmentHasherComponent.commitment;

    // Comparators
    signal check_aX, check_aY;
    signal check_bX, check_bY;
    signal check_cX, check_cY;

    check_aX <== aX - guessX;
    check_aY <== aY - guessY;
    check_bX <== bX - guessX;
    check_bY <== bY - guessY;
    check_cX <== cX - guessX;
    check_cY <== cY - guessY;

    // Check if any of the comparisons are zero
    component isz_aX = IsZero();
    component isz_aY = IsZero();
    component isz_bX = IsZero();
    component isz_bY = IsZero();
    component isz_cX = IsZero();
    component isz_cY = IsZero();

    isz_aX.in <== check_aX;
    isz_aY.in <== check_aY;
    isz_bX.in <== check_bX;
    isz_bY.in <== check_bY;
    isz_cX.in <== check_cX;
    isz_cY.in <== check_cY;

    // Aggregate results
    signal match_a, match_b, match_c;
    signal match_any;

    match_a <== isz_aX.out * isz_aY.out;
    match_b <== isz_bX.out * isz_bY.out;
    match_c <== isz_cX.out * isz_cY.out;

    match_any <== match_a + match_b + match_c;

    component isz_final = IsZero();
    isz_final.in <== 1 - match_any;
    isz_final.out ==> result;

    log(result);
    log(commitment);
}

component main {public [guessX, guessY]} = proveWrong();