import 'dart:math';

/// Configuration parameters
const int dimension = 256; // Dimension of the lattice
const int modulus = 3329; // Modulus for calculations
const int errorRange = 5; // Error range for added noise (just to test)

/// Helper function: Generates a random matrix A.
List<List<int>> generateRandomMatrix(int rows, int cols, int modulus) {
  final random = Random.secure();
  return List.generate(rows, (_) => List.generate(cols, (_) => random.nextInt(modulus)));
}

/// Helper function: Generates a random vector.
List<int> generateRandomVector(int size, int modulus) {
  final random = Random.secure();
  return List.generate(size, (_) => random.nextInt(modulus));
}

/// Generates public and private key pairs.
Map<String, dynamic> generateKeys(int dimension, int modulus) {
  final a = generateRandomMatrix(dimension, dimension, modulus); // Matrix A
  final privateKey = generateRandomVector(dimension, modulus); // Private key
  final errorVector = generateRandomVector(dimension, errorRange); // Error vector

  final publicKey = List<int>.generate(dimension, (i) {
    int sum = 0;
    for (int j = 0; j < dimension; j++) {
      sum += (a[i][j] * privateKey[j]) % modulus;
    }
    return (sum + errorVector[i]) % modulus;
  });

  return {
    'publicKey': {'A': a, 'b': publicKey, 'errorVector': errorVector}, // Include error vector in public key
    'privateKey': privateKey, // Private key
  };
}

/// Restores the public key from the private key using the same matrix A and error vector.
Map<String, dynamic> restorePublicKey(List<int> privateKey, List<List<int>> a, List<int> errorVector, int modulus) {
  final publicKey = List<int>.generate(dimension, (i) {
    int sum = 0;
    for (int j = 0; j < dimension; j++) {
      sum += (a[i][j] * privateKey[j]) % modulus;
    }
    return (sum + errorVector[i]) % modulus; // Add error vector part
  });
  return {'A': a, 'b': publicKey, 'errorVector': errorVector}; // Return restored public key with error vector
}

/// Helper function to compare two lists of integers
bool listsAreEqual(List<int> list1, List<int> list2) {
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
}

void main(List<String> arguments) {
  // Step 1: Generate keys
  final keys = generateKeys(dimension, modulus);
  final publicKey = keys['publicKey'];
  final privateKey = keys['privateKey'];
  final matrixA = publicKey['A']; // Save the matrix A for later restoration
  final errorVector = publicKey['errorVector']; // Save error vector for later restoration

  // Step 2: Restore public key from private key and validate using the saved matrix A and error vector
  final restoredPublicKey = restorePublicKey(privateKey, matrixA, errorVector, modulus);

  // Step 3: Check if the restored public key is correct
  if (listsAreEqual(restoredPublicKey['b'], publicKey['b'])) {
    print('The restored public key is valid.');
  } else {
    print('The restored public key is invalid.');
  }
}
