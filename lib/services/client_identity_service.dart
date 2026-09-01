import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientIdentityService {
  // ==========================================================
  // FIREBASE
  // ==========================================================

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==========================================================
  // UTILISATEUR ACTUEL
  // ==========================================================

  static User? get currentUser {
    return _auth.currentUser;
  }

  // ==========================================================
  // VÉRIFIER SI UN CLIENT EST CONNECTÉ
  // ==========================================================

  static bool get isClientConnected {
    return _auth.currentUser != null;
  }

  // ==========================================================
  // OBTENIR / CRÉER L'ID UNIQUE DU CLIENT
  // ==========================================================

  static Future<String> getClientId() async {
    // --------------------------------------------------------
    // Un utilisateur existe déjà
    // --------------------------------------------------------

    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    // --------------------------------------------------------
    // Aucun utilisateur → création anonyme
    // --------------------------------------------------------

    final resultat =
        await _auth.signInAnonymously();

    final nouveauUser =
        resultat.user;

    if (nouveauUser == null) {
      throw Exception(
        'Impossible de créer l’identité du client.',
      );
    }

    return nouveauUser.uid;
  }

  // ==========================================================
  // OBTENIR LE NOM DU CLIENT
  // ==========================================================

  static Future<String?> getClientName() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _firestore
            .collection('clients')
            .doc(user.uid)
            .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    final nom = data['nom'];

    if (nom == null) {
      return null;
    }

    final nomString =
        nom.toString().trim();

    if (nomString.isEmpty) {
      return null;
    }

    return nomString;
  }

  // ==========================================================
  // OBTENIR LE NUMÉRO DE TÉLÉPHONE
  //
  // Avec l'authentification anonyme, il n'y a normalement
  // aucun numéro de téléphone.
  // ==========================================================

  static Future<String?> getClientPhone() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return user.phoneNumber;
  }

  // ==========================================================
  // ENREGISTRER / METTRE À JOUR LE NOM DU CLIENT
  // ==========================================================

  static Future<void> saveClientName(
    String nom,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Aucune identité client.',
      );
    }

    final nomPropre =
        nom.trim();

    if (nomPropre.isEmpty) {
      throw Exception(
        'Le nom du client est obligatoire.',
      );
    }

    final clientRef =
        _firestore
            .collection('clients')
            .doc(user.uid);

    // --------------------------------------------------------
    // Vérifier si le client existe déjà
    // --------------------------------------------------------

    final document =
        await clientRef.get();

    final donnees =
        <String, dynamic>{
      'clientId': user.uid,
      'nom': nomPropre,
      'typeCompte': 'anonyme',
      'updatedAt':
          FieldValue.serverTimestamp(),
    };

    // --------------------------------------------------------
    // createdAt uniquement à la création
    // --------------------------------------------------------

    if (!document.exists) {
      donnees['createdAt'] =
          FieldValue.serverTimestamp();
    }

    await clientRef.set(
      donnees,
      SetOptions(
        merge: true,
      ),
    );
  }

  // ==========================================================
  // OBTENIR TOUTES LES INFORMATIONS DU CLIENT
  // ==========================================================

  static Future<Map<String, dynamic>?>
      getClientData() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _firestore
            .collection('clients')
            .doc(user.uid)
            .get();

    if (!document.exists) {
      return null;
    }

    final data =
        document.data();

    if (data == null) {
      return null;
    }

    return {
      ...data,
      'clientId': user.uid,
      'telephone':
          user.phoneNumber,
    };
  }

  // ==========================================================
  // DÉCONNECTER LE CLIENT
  // ==========================================================

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}