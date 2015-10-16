open CoreCrypto
open Platform

let digit_to_int c = match c with
  | '0'..'9' -> Char.code c - Char.code '0'
  | 'a'..'f' -> 10 + Char.code c - Char.code 'a'
  | _ -> failwith "hex_to_char: invalid hex digit"

let hex_to_char a b =
  Char.chr ((digit_to_int a) lsl 4 + digit_to_int b)

let char_to_hex c =
  let n = Char.code c in
  let digits = "0123456789abcdef" in
  digits.[n lsr 4], digits.[n land 0x0f]

let string_to_hex s =
  let n = String.length s in
  let buf = Buffer.create n in
  for i = 0 to n - 1 do
    let d1,d2 = char_to_hex s.[i] in
    Buffer.add_char buf d1;
    Buffer.add_char buf d2;
  done;
  Buffer.contents buf

let hex_to_string s =
  let n = String.length s in
  if n mod 2 <> 0 then
    failwith "hex_to_string: invalid length"
  else
    let res = String.create (n/2) in
    let rec aux i =
      if i >= n then ()
      else (
        String.set res (i/2) (hex_to_char s.[i] s.[i+1]);
        aux (i+2)
      )
    in
    aux 0;
    res

let hex_to_bytes s = bytes_of_string (hex_to_string s)
let bytes_to_hex b = string_to_hex (string_of_bytes b)

type test_vector = {
  cipher: aead_cipher;
  key: string;
  iv : string;
  aad: string;
  tag: string;
  plaintext: string;
  ciphertext: string;
}

let print_test_vector v =
  Printf.printf "key:\t\t%S\niv:\t\t%S\naad:\t\t%S\ntag:\t\t%S\nplaintext:\t%S\nciphertext:\t%S\n"
    v.key v.iv v.aad v.tag v.plaintext v.ciphertext

let test v =
  let key = hex_to_bytes v.key in
  let iv  = hex_to_bytes v.iv  in
  let aad = hex_to_bytes v.aad in
  let plaintext = hex_to_bytes v.plaintext in
  let c = aead_encrypt v.cipher key iv aad plaintext in
  let c',t = Bytes.split c (Bytes.length c - 16) in
  if not(bytes_to_hex c' = v.ciphertext && bytes_to_hex t = v.tag) then
    false
  else
    let p = aead_decrypt v.cipher key iv aad c in
    p = Some plaintext

let test_vectors = [
{
  cipher = AES_128_GCM;
  key = "00000000000000000000000000000000";
  iv  = "000000000000000000000000";
  aad = "";
  tag = "58e2fccefa7e3061367f1d57a4e7455a";
  plaintext  = "";
  ciphertext = "";
};
{
  cipher = AES_128_GCM;
  key = "00000000000000000000000000000000";
  iv  = "000000000000000000000000";
  aad = "";
  tag = "ab6e47d42cec13bdf53a67b21257bddf";
  plaintext  = "00000000000000000000000000000000";
  ciphertext = "0388dace60b6a392f328c2b971b2fe78";
};
{
  cipher = AES_128_GCM;
  key = "feffe9928665731c6d6a8f9467308308";
  iv  = "cafebabefacedbaddecaf888";
  aad = "";
  tag = "4d5c2af327cd64a62cf35abd2ba6fab4";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255";
  ciphertext = "42831ec2217774244b7221b784d0d49ce3aa212f2c02a4e035c17e2329aca12e21d514b25466931c7d8f6a5aac84aa051ba30b396a0aac973d58e091473f5985";
};
{
  cipher = AES_128_GCM;
  key = "feffe9928665731c6d6a8f9467308308";
  iv  = "cafebabefacedbaddecaf888";
  aad = "feedfacedeadbeeffeedfacedeadbeefabaddad2";
  tag = "5bc94fbc3221a5db94fae95ae7121a47";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39";
  ciphertext = "42831ec2217774244b7221b784d0d49ce3aa212f2c02a4e035c17e2329aca12e21d514b25466931c7d8f6a5aac84aa051ba30b396a0aac973d58e091";
};
{
  cipher = AES_128_GCM;
  key = "feffe9928665731c6d6a8f9467308308";
  iv  = "cafebabefacedbad";
  aad = "feedfacedeadbeeffeedfacedeadbeefabaddad2";
  tag = "3612d2e79e3b0785561be14aaca2fccb";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39";
  ciphertext = "61353b4c2806934a777ff51fa22a4755699b2a714fcdc6f83766e5f97b6c742373806900e49f24b22b097544d4896b424989b5e1ebac0f07c23f4598";
};
{
  cipher = AES_128_GCM;
  key = "feffe9928665731c6d6a8f9467308308";
  iv  = "9313225df88406e555909c5aff5269aa6a7a9538534f7da1e4c303d2a318a728c3c0c95156809539fcf0e2429a6b525416aedbf5a0de6a57a637b39b";
  aad = "feedfacedeadbeeffeedfacedeadbeefabaddad2";
  tag = "619cc5aefffe0bfa462af43c1699d050";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39";
  ciphertext = "8ce24998625615b603a033aca13fb894be9112a5c3a211a8ba262a3cca7e2ca701e4a9a4fba43c90ccdcb281d48c7c6fd62875d2aca417034c34aee5";
};
{
  cipher = AES_256_GCM;
  key = "0000000000000000000000000000000000000000000000000000000000000000";
  iv  = "000000000000000000000000";
  aad = "";
  tag = "530f8afbc74536b9a963b4f1c4cb738b";
  plaintext  = "";
  ciphertext = "";
};
{
  cipher = AES_256_GCM;
  key = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308";
  iv  = "cafebabefacedbaddecaf888";
  aad = "";
  tag = "b094dac5d93471bdec1a502270e3cc6c";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255";
  ciphertext = "522dc1f099567d07f47f37a32a84427d643a8cdcbfe5c0c97598a2bd2555d1aa8cb08e48590dbb3da7b08b1056828838c5f61e6393ba7a0abcc9f662898015ad";
};
{
  cipher = AES_256_GCM;
  key = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308";
  iv  = "cafebabefacedbaddecaf888";
  aad = "";
  tag = "b094dac5d93471bdec1a502270e3cc6c";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255";
  ciphertext = "522dc1f099567d07f47f37a32a84427d643a8cdcbfe5c0c97598a2bd2555d1aa8cb08e48590dbb3da7b08b1056828838c5f61e6393ba7a0abcc9f662898015ad";
};
{
  cipher = AES_256_GCM;
  key = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308";
  iv  = "cafebabefacedbaddecaf888";
  aad = "feedfacedeadbeeffeedfacedeadbeefabaddad2";
  tag = "76fc6ece0f4e1768cddf8853bb2d551b";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39";
  ciphertext = "522dc1f099567d07f47f37a32a84427d643a8cdcbfe5c0c97598a2bd2555d1aa8cb08e48590dbb3da7b08b1056828838c5f61e6393ba7a0abcc9f662";
};
{
  cipher = AES_256_GCM;
  key = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308";
  iv  = "cafebabefacedbad";
  aad = "feedfacedeadbeeffeedfacedeadbeefabaddad2";
  tag = "3a337dbf46a792c45e454913fe2ea8f2";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39";
  ciphertext = "c3762df1ca787d32ae47c13bf19844cbaf1ae14d0b976afac52ff7d79bba9de0feb582d33934a4f0954cc2363bc73f7862ac430e64abe499f47c9b1f";
};
{
  cipher = AES_256_GCM;
  key = "feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308";
  iv  = "9313225df88406e555909c5aff5269aa6a7a9538534f7da1e4c303d2a318a728c3c0c95156809539fcf0e2429a6b525416aedbf5a0de6a57a637b39b";
  aad = "feedfacedeadbeeffeedfacedeadbeefabaddad2";
  tag = "a44a8266ee1c8eb0c8b5d4cf5ae9f19a";
  plaintext  = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39";
  ciphertext = "5a8def2f0c9e53f1f75d7853659e2a20eeb2b22aafde6419a058ab4f6f746bf40fc0c3b780f244452da3ebf1c5d82cdea2418997200ef82e44ae7e3f";
};
{
  cipher = AES_128_GCM;
  key = "00000000000000000000000000000000";
  iv  = "000000000000000000000000";
  aad = "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255522dc1f099567d07f47f37a32a84427d643a8cdcbfe5c0c97598a2bd2555d1aa8cb08e48590dbb3da7b08b1056828838c5f61e6393ba7a0abcc9f662898015ad";
  tag = "5fea793a2d6f974d37e68e0cb8ff9492";
  plaintext  = "";
  ciphertext = "";
};
{
  cipher = AES_128_GCM;
  key = "00000000000000000000000000000000";
  iv  = "000000000000000000000000";
  aad = "";
  tag = "9dd0a376b08e40eb00c35f29f9ea61a4";
  plaintext  = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  ciphertext = "0388dace60b6a392f328c2b971b2fe78f795aaab494b5923f7fd89ff948bc1e0200211214e7394da2089b6acd093abe0";
};
{
  cipher = AES_128_GCM;
  key = "00000000000000000000000000000000";
  iv  = "000000000000000000000000";
  aad = "";
  tag = "98885a3a22bd4742fe7b72172193b163";
  plaintext  = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  ciphertext = "0388dace60b6a392f328c2b971b2fe78f795aaab494b5923f7fd89ff948bc1e0200211214e7394da2089b6acd093abe0c94da219118e297d7b7ebcbcc9c388f28ade7d85a8ee35616f7124a9d5270291";
};
{
  cipher = AES_128_GCM;
  key = "00000000000000000000000000000000";
  iv  = "000000000000000000000000";
  aad = "";
  tag = "cac45f60e31efd3b5a43b98a22ce1aa1";
  plaintext  = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  ciphertext = "0388dace60b6a392f328c2b971b2fe78f795aaab494b5923f7fd89ff948bc1e0200211214e7394da2089b6acd093abe0c94da219118e297d7b7ebcbcc9c388f28ade7d85a8ee35616f7124a9d527029195b84d1b96c690ff2f2de30bf2ec89e00253786e126504f0dab90c48a30321de3345e6b0461e7c9e6c6b7afedde83f40";
};
{
  cipher = AES_128_GCM;
  key = "00000000000000000000000000000000";
  iv  = "ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  aad = "";
  tag = "566f8ef683078bfdeeffa869d751a017";
  plaintext  = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  ciphertext = "56b3373ca9ef6e4a2b64fe1e9a17b61425f10d47a75a5fce13efc6bc784af24f4141bdd48cf7c770887afd573cca5418a9aeffcd7c5ceddfc6a78397b9a85b499da558257267caab2ad0b23ca476a53cb17fb41c4b8b475cb4f3f7165094c229c9e8c4dc0a2a5ff1903e501511221376a1cdb8364c5061a20cae74bc4acd76ceb0abc9fd3217ef9f8c90be402ddf6d8697f4f880dff15bfb7a6b28241ec8fe183c2d59e3f9dfff653c7126f0acb9e64211f42bae12af462b1070bef1ab5e3606";
};
{
  cipher = AES_128_GCM;
  key = "00000000000000000000000000000000";
  iv  = "ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  aad = "";
  tag = "8b307f6b33286d0ab026a9ed3fe1e85f";
  plaintext  = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  ciphertext = "56b3373ca9ef6e4a2b64fe1e9a17b61425f10d47a75a5fce13efc6bc784af24f4141bdd48cf7c770887afd573cca5418a9aeffcd7c5ceddfc6a78397b9a85b499da558257267caab2ad0b23ca476a53cb17fb41c4b8b475cb4f3f7165094c229c9e8c4dc0a2a5ff1903e501511221376a1cdb8364c5061a20cae74bc4acd76ceb0abc9fd3217ef9f8c90be402ddf6d8697f4f880dff15bfb7a6b28241ec8fe183c2d59e3f9dfff653c7126f0acb9e64211f42bae12af462b1070bef1ab5e3606872ca10dee15b3249b1a1b958f23134c4bccb7d03200bce420a2f8eb66dcf3644d1423c1b5699003c13ecef4bf38a3b60eedc34033bac1902783dc6d89e2e774188a439c7ebcc0672dbda4ddcfb2794613b0be41315ef778708a70ee7d75165c";
};
{
  cipher = AES_128_GCM;
  key = "843ffcf5d2b72694d19ed01d01249412";
  iv  = "dbcca32ebf9b804617c3aa9e";
  aad = "00000000000000000000000000000000101112131415161718191a1b1c1d1e1f";
  tag = "3b629ccfbc1119b7319e1dce2cd6fd6d";
  plaintext  = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f";
  ciphertext = "6268c6fa2a80b2d137467f092f657ac04d89be2beaa623d61b5a868c8f03ff95d3dcee23ad2f1ab3a6c80eaf4b140eb05de3457f0fbc111a6b43d0763aa422a3013cf1dc37fe417d1fbfc449b75d4cc5";
};
]

let () =
  let passed = ref 0 in
  let total  = ref 0 in
  let doit v =
    total := !total + 1;
    if test v then
      passed := !passed + 1
    else (
      Printf.printf "Test failed:\n";
      print_test_vector v
    )
  in
  List.iter doit test_vectors;
  Printf.printf "%d/%d tests passed\n" !passed !total